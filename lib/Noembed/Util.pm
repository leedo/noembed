package Noembed::Util;

use Encode;
use JSON ();
use AnyEvent::HTTP ();
use Text::MicroTemplate ();
use HTML::TreeBuilder;

use Noembed::Pygmentize;
use Noembed::Imager;

my $pygment = Noembed::Pygmentize->new;
my $imager = Noembed::Imager->new;

sub http_get {
  my $cb = pop;
  my ($url, @options) = @_;

  die "no callback" unless $cb;

  AnyEvent::HTTP::http_request get => $url,
    persistent => 0,
    keepalive  => 0,
    @options,
    sub {
      my ($body, $headers) = @_;

      if ($headers->{'content-type'} =~ /^text\//i) {
        $body = decode("utf8", $body);
      }
      $cb->($body, $headers);
    };
}

sub http_resolve {
  my ($url, $cb) = @_;

  Noembed::Util::http_get $url, recurse => 0, sub {
    my ($body, $headers) = @_;

    if ($headers->{location}) {
      $url = $headers->{location};
    }
    elsif ($body and $body =~ /URL=([^"]+)"/) {
      $url = $1;
    }

    $cb->($url);
  };
}

sub dimensions {
  my ($url, $req, $cb) = @_;

  my $maxw = $req->parameters->{maxwidth};
  my $maxh = $req->parameters->{maxheight};

  Noembed::Util::http_get $url, sub {
    my ($body, $headers) = @_;
    if ($headers->{Status} == 200) {
      $imager->dimensions($body, sub {
        my ($w, $h) = @_;

        if ($maxh and $h > $maxh) {
          $w = $w * ($maxh / $h);
          $h = $maxh;
        }
        if ($maxw and $w > $maxw) {
          $h = $h * ($maxw / $w);
          $w = $maxw;
        }

        $cb->(int($w), int($h));
      });
    }
    else {
      $cb->("", "");
    }
  };
}

sub colorize {
  my $cb = pop;
  my ($text, %options) = @_;
  $pygment->colorize($text, %options, $cb);
}

sub html {
  Text::MicroTemplate::encoded_string($_[0]);
}

sub clean_html {
  my $html = shift;
  my $tree = HTML::TreeBuilder->new_from_content($html);
  $tree->ignore_ignorable_whitespace(0);
  $_->delete for $tree->find("script");

  $tree->look_down(sub {
    my $elem = shift;
    my %attr = $elem->all_external_attr;
    $elem->attr($_, undef) for grep {/^on/i or $attr{$_} =~ /^javascript:/i} keys %attr;
    return ();
  });

  $html = $tree->as_HTML;
  $tree->delete;

  html($html);
}

sub json_res {
  my ($data, @headers) = @_;
  my $body = JSON::encode_json $data;

  [
    200,
    [
      @headers,
      'Content-Type', 'text/javascript; charset=utf-8',
      'Content-Length', length $body
    ],
    [$body]
  ];
}

1;

=pod

=head1 NAME

Noembed::Util - useful functions for Noembed

=head1 DESCRIPTION

This package includes a number of functions that are used throughout L<Noembed>.
Many of these are asynchronous and accept a callback as the last argument.

=head1 FUNCTIONS

=over 4

=item http_get ($url, %options, $callback)

Download a URL and call the callback when it is completed. See
L<AnyEvent::HTTP> for a list of options.

  Noembed::Util::http_get $url, sub {
    my ($body, $headers) = @_;
    if ($headers->{Status} == 200) {
      ... do some work.
    }
  };

=item http_resolve ($url, $callback)

Determine what location, if any, a URL redirects to.

  Noembed::Util::http_resolve "http://bit.ly/abcd", sub {
    my $resolved = shift;
    ... do some work.
  };

=item colorize ($text, %options, $callback)

Syntax highlight a block of text. Valid options include: C<language>,
C<filename>. See L<Noembed::Pygmentize> for more options.

=item dimensions ($image_url, [$request,] $callback)

Download an image url and determine the height and width. If a
L<Noembed::Request> object is included this will check for the
C<maxwidth> and C<maxheight> parameters and scale down the dimensions
based on these limits.

=item html ($text)

Returns a version of C<$text> that will not be automatically escaped 
when used inside a template.

=item clean_html ($text)

Similar to the C<html> function, but strips out any potential
scripts.  That includes C<script> tags, event handlers such as
C<onclick> or C<href="javascript:...">. B<Currently, this does not
preserve all white space.>

=item json_res ($hashref or $arrayref)

Accepts either a hash or array reference and returns a valid PSGI
response. The response will have a C<text/javascript> Content-Type
and the correct Content-Length set.

=back

=head1 SEE ALSO

L<Noembed::Pygmentize>, L<Noembed::Imager>

=cut

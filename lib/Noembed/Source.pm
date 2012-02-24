package Noembed::Source;

use Carp;
use JSON ();
use URI;
use URI::QueryParam;
use Scalar::Util qw/blessed/;
use Exporter;
use Noembed::Util;

sub new {
  my ($class, %args) = @_;

  my $self = bless {%args}, $class;
  croak "render is required" unless defined $self->{render};

  $self->prepare_source;
  $self->{patterns} = [ map {qr{^$_}i} $self->patterns ];
  *{$class.'::html'} = *Noembed::Util::html;

  return $self;
}

sub prepare_source { }

sub pre_download {
  my ($self, $req, $cb) = @_;
  $cb->($req);
}

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  $cb->($body);
}

sub filename {
  my ($self, $ext) = @_;
  my ($name) = ref($self) =~ /:([^:]+)$/;
  return $ext ? "$name.$ext" : $name;
}

sub render {
  my $self = shift;
  $self->{render}->($self->filename("html"), @_);
}

sub build_url {
  my ($self, $req) = @_;
  return $req->content_url;
}

sub request_url {
  my ($self, $req) = @_;

  my $uri = $self->build_url($req);
  my $params = $req->parameters;

  unless (blessed($uri) and $uri->can("query_param")) {
    $uri = URI->new($uri);
  }

  for my $option ($self->options) {
    if (defined $params->{$option}) {
      $uri->query_param($option => $params->{$option});
    }
  }

  return $uri->as_string;
}

sub serialize {
  croak "must override serialize method";
}

sub patterns {
  croak "must override patterns method";
}

sub shorturls { }
sub options { }

sub matches {
  my ($self, $req) = @_;

  for my $re (@{$self->{patterns}}) {
    if (my (@caps) = $req->url =~ $re) {
      $req->pattern($re);
      return 1;
    }
  }

  return 0;
}

sub finalize {
  my ($self, $body, $req) = @_;

  my $data = {
    title => $req->url,
    provider_name => $self->provider_name,
    url => $req->url,
    # overrides the above properties
    %{ $self->serialize($body, $req) },
    type  => "rich",
  };

  return $data;
}

1;

=pod

=head1 NAME

Noembed::Source - a base class for embeddable Noembed sources

=head1 DESCRIPTION

This is a base class that is meant to be extended to create Noembed
sources.  There are a few methods that need to be overridden for
it to be usable.

=head1 METHODS

=head2 REQUIRED

=over 4

=item patterns

Must return a list of strings that can be compiled into valid regular
expressions. e.g. C<"http://www\.google\.com/.+">

=item provider_name

Must return the name of the provider. e.g. C<Google>

=item serialize ($body, $req)

Receives the downloaded content and embed request. This must
return a hash reference containing C<html> and C<title> keys.
Additional key/value pairs will be included in the JSON response
to the client.

=back

=head2 OPTIONAL

=over 4

=item prepare_source

A convenience method called when noembed starts. Use it to set up
your source (e.g. build a C<Web::Scraper> attribute.)

=item build_url ($req)

This method should return the URL to be downloaded. It can return
either a string or URI object. By default it returns the URL provided
in the embed request.

=item shorturls

Like C<patterns>, this must return a list of strings that can be
compiled into valid regular expressions. If a URL matches one of
these patterns Noembed will resolve it and handle new URL.

=item options

Can return a list of parameter names that will be included with the
final content URL request. One useful example of this is in C<autoplay>
option for L<Noembed::Source::YouTube|YouTube>.

=back

=head2 HOOKS

=over 4

=item pre_download ($req, $callback)

Use this hook to run asynchronous code before the content URL is
downloaded. This can be useful if you need to make additional HTTP
requests to determine the final content url. Note: you B<must> call
the callback, or the client request will hang indefinitely.

In this example from L<Noembed::Source::Facebook> source the user's
ID is required to build the final URL.  C<Noembed::Util::http_get>
is used to fetch the user's profile info.

  sub pre_download {
    my ($self, $req, $cb) = @_;
    my $profile = "https://graph.facebook.com/".$req->captures->[0];

    Noembed::Util::http_get $profile, sub {
      my ($body, $headers) = @_;
      my $data = decode_json $body;
      $req->content_url("https://graph.facebook.com/$data->{id}_".$req->captures->[1]);
      $cb->($req);
    };
  }

=item post_download ($body, $req, $callback)

Use this hook to run asynchronous code after the content is downloaded,
but before the serialize method is called.

This example from L<Noembed::Source::Gist> uses C<Noembed::Util::colorize>
to asynchronously syntax highlight the returned files. The provided
callback is run only after all the files have been highlighted.

  sub post_download {
    my ($self, $body, $req, $cb) = @_;
    my $gist = from_json $body;
    my $cv = AE::cv;

    for my $file (values %{$gist->{files}}) {
      $cv->begin;

      Noembed::Util::colorize $file->{content},
        language => lc $file->{language},
        filename => lc $file->{filename},
        sub {
          my $colorized = shift;
          $file->{content} = html($colorized);
          $cv->end;
        };
    }

    $cv->cb(sub {$cb->($gist)});
  }

=back

=head1 HTML TEMPLATES AND STYLESHEETS

This class also provides a render method. This method will search
for a template in C<./share/templates/> that matches the name of
the class (e.g. C<Google.pm> -> C<Google.html>). The render method
will pass arguments onto the template. See L<Text::MicroTemplate>
for template basics.

  package Noembed::Source::Dictionary;

  ...

  sub serialize {
    my ($self, $content) = @_;
    my $data = from_json $content;

    # render ./share/templates/Dictionary.html template,
    # passing in $data
    return {
      html  => $self->render($data),
      title => $data->{title},
    };
  }

If you create a similarly named stylesheet (C<Google.pm> ->
C<Google.css>) in C<./share/styles/>, it will automatically be
included in the C</noembed.css> file.

=head1 SEE ALSO

L<Noembed::Source::Gist>, L<Noembed::Source::Facebook>,
L<Noembed::Source::Wikipedia>

=cut

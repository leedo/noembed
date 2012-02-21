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
sub icon { }

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

This is a base class that is meant to be extended to create Noembed sources.
There are a few methods that need to be overridden for it to be usable.

=head1 OPTIONAL METHODS

=over 4

=item prepare_source

This is a convenience method called when noembed starts. Use it to set up your
source (e.g. build a Web::Scraper object.)

=back

=head1 REQUIRED METHODS

=over 4

=item patterns

Must return a list of strings that can be compiled into valid
regular expressions. e.g. "http://www\.google\.com/.+"

=item provider_name

Needs to return the name of the provider. e.g. "Google"

=item serialize ($body)

Accepts the downloaded content and must return a hash reference.
The hash reference should contain an 'html' and 'title' key. It can
optionally include a 'provider_name' key which will override the
provider_name method.

=back

=head1 HTML TEMPLATES AND STYLESHEETS

This class also provides a render method. This method will search for a
template in ./share/templates/ that matches the name of the class
(e.g. Google.pm -> Google.html). The render method will pass arguments
onto the template. See L<Text::MicroTemplate> for template basics.

If you create a similarly named stylesheet (Google.pm -> Google.css) in
./share/styles/, it will automatically be concatenated into the html.

=cut

package Noembed::Source;

use Carp;

sub new {
  my ($class, %args) = @_;

  my $self = bless {%args}, $class;
  croak "render is required" unless defined $self->{render};

  $self->prepare_source;
  $self->{patterns} = [ map {qr{^$_}i} $self->patterns ];

  return $self;
}

sub prepare_source { }

sub post_download {
  my ($self, $body, $cb) = @_;
  $cb->($body);
}

sub filename {
  my ($self, $ext) = @_;
  my ($name) = ref($self) =~ /:([^:]+)$/;
  return "$name.$ext";
}

sub render {
  my $self = shift;
  $self->{render}->($self->filename("html"), @_)->as_string;
}

sub request_url {
  my ($self, $req) = @_;
  return $req->url;
}

sub filter {
  croak "must override filter method";
}

sub patterns {
  croak "must override patterns method";
}

sub shorturls { }

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

sub serialize {
  my ($self, $body, $req, @data) = @_;

  my $data = {
    title => $req->url,
    provider_name => $self->provider_name,
    # overrides the above properties
    %{ $self->filter($body, $req, @data) },
    type  => "rich",
    url   => $req->url,
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

=item filter ($body)

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

package Noembed::Provider;

use Carp;
use JSON ();
use URI;
use URI::QueryParam;
use Scalar::Util qw/blessed/;
use Noembed::Util;
use HTML::Parser;

sub new {
  my ($class, %args) = @_;

  my $self = bless {%args}, $class;
  croak "render is required" unless defined $self->{render};

  $self->prepare_provider;

  $self->{patterns} = [ map {qr{^$_}i} $self->patterns ];

  return $self;
}

sub prepare_provider { }

sub surrogate_key {
  my $self = shift;
  my $class = ref($self);
  $class =~ s/^.*:://g;
  return lc $class;
}

sub filename {
  my ($self, $ext) = @_;
  my ($name) = ref($self) =~ /:([^:]+)$/;
  return $ext ? "$name.$ext" : $name;
}

sub render {
  my $self = shift;
  $self->{render}->($self->filename("html"), @_)
}

sub build_url {
  my ($self, $req) = @_;
  return $req->url;
}

sub rewrite_images {
  my $output = pop;
  my ($self, $w, $h) = @_;
  my $html = "";
  my $p = HTML::Parser->new(
    api_version => 3,
    handlers => {
      default => [
        sub {
          $html .= $_[0];
        }, "text"
      ],
      start => [
        sub {
          if ($_[0] eq "img") {
            $_[1]->{src} = $self->{image_prefix} . $_[1]->{src};
            my $attr = join " ", map {"$_=\"$_[1]->{$_}\""} sort keys %{$_[1]};
            $html .= "<$_[0] $attr>"
          }
          else {
            $html .= $_[2];
          }
        }, "tag,attr,text"
      ]
    }
  );
  $p->parse($output);
  $p->eof;
  return $html;
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
  my ($self, $req, $res) = @_;

  my $data = {
    title => $req->url,
    provider_name => $self->provider_name,
    url => $req->url,
    type  => "rich",
    # overrides the above properties
    %{ $self->serialize($res->decoded_content, $req) },
  };

  $data->{html} = $self->rewrite_images($data->{html});

  return $data;
}

1;

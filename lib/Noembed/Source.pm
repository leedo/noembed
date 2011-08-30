package Noembed::Source;

use Carp;

sub new {
  my ($class, %args) = @_;

  my $self = bless {%args}, $class;
  croak "render is required" unless defined $self->{render};

  $self->prepare_source;
  return $self;
}

sub prepare_source { }

sub filename {
  my ($self, $ext) = @_;
  my ($name) = ref($self) =~ /:([^:]+)$/;
  return "$name.$ext";
}

sub render {
  my $self = shift;
  $self->{render}->($self->filename("html"), @_)->as_string;
}

sub style {
  my $self = shift;
  
  # cache it
  unless (defined $self->{style}) {
    $self->{style} = do {
      my $file = Noembed::style_dir() . "/" . $self->filename("css");
      if (-r $file) {
        open my $fh, "<", $file;
        local $/;
        '<style type="text/css">'.<$fh>.'</style>';
      }
      else {
        "";
      }
    };
  }

  return $self->{style};
}

sub request_url {
  my ($self, $req) = @_;
  return $req->url;
}

sub filter {
  my ($self, $body) = @_;
  croak "must override filter method";
}

sub matches {
  croak "must override matches method";
}

sub prepare {
  my ($self, $body, $req) = @_;

  my $data = {
    title => $req->url,
    provider_name => $self->provider_name,
    # overrides the above properties
    %{ $self->filter($body, $req) },
    type  => "rich",
    url   => $req->url,
  };

  $data->{html} .= $self->style;
  return $data;
}

1;

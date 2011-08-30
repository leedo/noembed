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
  $self->{style} ||= do {
    my $file = Noembed::style_dir() . "/" . $self->filename("css");
    if (-r $file) {
      open my $fh, "<", $file;
      local $/;
      <$fh>;
    }
  };
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
  my $data = $self->filter($body, $req);

  if ($self->style) {
    $data->{html} .= '<style type="text/css">'.$self->style.'</style>';
  }

  $data->{type} = "rich";
  $data->{url} = $req->url;
  $data->{title} ||= $req->url;
  $data->{provider_name} ||= $self->provider_name;

  return $data;
}

1;

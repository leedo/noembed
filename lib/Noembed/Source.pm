package Noembed::Source;

use Carp;
use Encode;
use JSON;
use AnyEvent::HTTP;

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
  $self->{render}->($self->filename("html"), @_);
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

sub download {
  my ($self, $req, $cb) = @_;

  my $service = $self->request_url($req);
  my $nb = $req->env->{'psgi.nonblocking'};
  my $cv = AE::cv;

  http_request "get", $service, {
      persistent => 0,
      keepalive  => 0,
    },
    sub {
      my ($body, $headers) = @_;

      $body = decode("utf8", $body);

      if ($headers->{Status} == 200) {
        eval {
          my $data = $self->filter($body, $req);
          $data->{html} .= '<style type="text/css">'.$self->style.'</style>';
          $data->{type} = "rich";
          $data->{url} = $req->url;
          $data->{title} ||= $req->url;
          $data->{provider_name} ||= $self->provider_name;
          $cb->( encode_json($data), "" );
        };
        carp "Error after http request: $@" if $@;
      }
      else {
        $cb->("", $headers->{Reason});
      }

      $cv->send unless $nb;
    };

  $cv->recv unless $nb;
}

1;

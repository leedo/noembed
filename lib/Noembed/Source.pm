package Noembed::Source;

use JSON;
use AnyEvent::HTTP;

sub new {
  my ($class, %args) = @_;
  my $self = bless {%args}, $class;

  $self->prepare_source if $self->can('prepare_source');

  return $self;
}

sub request_url {
  my ($self, $req) = @_;
  return $req->parameters->{url};
}

sub filter {
  my $self = shift;
  return @_;
}

sub matches {
  die "must override matches method";
}

sub download {
  my ($self, $req, $cb) = @_;

  my $service = $self->request_url($req);
  my $nb = $req->env->{'psgi.nonblocking'};
  my $cv = AE::cv;

  http_request "get", $service, sub {
    my ($body, $headers) = @_;

    if ($headers->{Status} == 200) {
      eval {
        my $data = $self->filter($body);
        $data->{type} = "rich";
        $data->{url} = $url;
        $cb->( encode_json($data), "" );
        $cv->send unless $nb;
      };
      return unless $@;
      warn "Error after http request: $@";
      $cv->send unless $nb;
    }

    $cb->("", $headers->{Reason});
  };

  $cv->recv unless $nb;
}

1;

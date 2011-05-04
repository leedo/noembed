package Noembed::Source;

use JSON;
use AnyEvent::HTTP;

sub new {
  my ($class, %args) = @_;
  my $self = bless {}, $class;

  $self->prepare_source if $self->can('prepare_source');

  return $self;
}

sub request_url {
  die "must override request_url method";
}

sub filter {
  my $self = shift;
  return @_;
}

sub matches {
  die "must override matches method";
}

sub download {
  my ($self, $url, $cb) = @_;

  my $service = $self->request_url($url);

  http_request "get", $service, sub {
    my ($body, $headers) = @_;

    if ($headers->{Status} == 200) {
      eval {
        my $data = $self->filter($body);
        $data->{type} = "rich";
        $data->{url} = $url;
        $cb->( encode_json($data), "" );
      };
      return unless $@;
      warn "Error after http request: $@";
    }

    $cb->("", $headers->{Reason});
  };
}

1;

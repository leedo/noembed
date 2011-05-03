package Noembed::Source;

use AnyEvent::HTTP;

sub new {
  my ($class, %args) = @_;
  bless {}, $class;
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
        $cb->( $self->filter($body, "") );
      };
      return unless $@;
      warn "Error after http request: $@";
    }

    $cb->("", $headers->{Reason});
  };
}

1;

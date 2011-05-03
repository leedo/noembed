package Noembed::Source;

use AnyEvent::HTTP;

sub request_url {
  die "must override request_url method";
}

sub filter {
  my $self = shift;
  return @_;
}

sub patterns {
  die "must override patterns method";
}

sub matches {
  my ($self, $url) = @_;
  for my $pattern ($self->patterns) {
    return 1 if $url =~ $pattern;
  }

  return 0;
}

sub download {
  my ($self, $url, $cb) = @_;

  http_request "get", $url, sub {
    my ($headers, $body) = @_;

    if ($headers->{Status} == 200) {
      eval {
        $cb->( $self->filter($body) );
      };
      return unless $@;
      warn "Error after http request: $@";
    }

    $cb->();
  };
}

1;

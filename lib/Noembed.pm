package Noembed;

use Module::Find ();
use Class::Load;
use Plack::Request;
use JSON;

use parent 'Plack::Component';

our $VERSION = "0.01";

sub prepare_app {
  my $self = shift;

  $self->{sources} ||= [ Module::Find::findsubmod("Noembed::Source") ];
  $self->{providers} = [];

  $self->register_provider($_) for @{$self->{sources}};
  delete $self->{sources};
}

sub call {
  my ($self, $env) = @_;

  my $req = Plack::Request->new($env);
  return error("url parameter is required") unless $req->parameters->{url};
  return $self->handle_url($req);
}

sub handle_url {
  my ($self, $req) = @_;

  my $url = $req->parameters->{url};
  
  for my $provider (@{$self->{providers}}) {
    if ($provider->matches($url)) {
      return _handle_match($provider, $req);
      last;
    }
  }

  error("no matching providers found for $url");
}

sub _handle_match {
  my ($provider, $req) = @_;

  return sub {
    my $respond = shift;

    $provider->download($req, sub {
      my ($body, $error) = shift;
      $respond->($error ? error($error) : json_res($body));
    });
  };
}

sub json_res {
  my $body = shift;

  [
    200,
    [
      'Content-Type', 'application/json;charset=utf-8',
      'Content-Length', length $body
    ],
    [$body]
  ];
}

sub error {
  my $message = shift;
  my $body = encode_json {error => ($message || "unknown error")};
  json_res $body;
}

sub register_provider {
  my ($self, $class) = @_;

  if ($class !~ /^Noembed::Source::/ and $class !~ s/^\+//) {
    $class = "Noembed::Source::$class";
  }

  my ($loaded, $error) = Class::Load::try_load_class($class);
  if ($loaded) {
    my $provider = $class->new;
    push @{ $self->{providers} }, $provider;
  }
  else {
    warn "Could not load provider $class: $error";
  }
}

1;

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
  $self->{locks} = {};

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

  return sub {
    my $respond = shift;
    my $url = $req->parameters->{url};

    $self->add_lock($url, $respond);
  
    for my $provider (@{$self->{providers}}) {
      if ($provider->matches($url)) {
        $provider->download($req, sub {
          my ($body, $error) = shift;
          $self->end_lock($url, $error ? error($error) : json_res($body));
        });
        return;
      }
    }

    $self->end_lock(error("no matching providers found for $url"));
  }
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

sub add_lock {
  my ($self, $url, $respond) = @_;

  $self->{locks}{$url} ||= [];
  push @{$self->{locks}{$url}}, $respond;
}

sub end_lock {
  my ($self, $url, $response) = @_;
  $_->($response) for @{$self->{locks}{$url}};
  delete $self->{locks}{$url};
}

sub has_lock {
  my ($self, $url) = @_;
  exists $self->{locks}{$url} and @{$self->{locks}{$url}};
}

1;

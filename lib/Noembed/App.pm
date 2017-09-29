package Noembed::App;

use Module::Find ();
use Class::Load;
use Text::MicroTemplate::File;
use JSON::XS;
use Cache::Memcached;
use Storable qw(freeze thaw);

use Noembed::Util;
use Noembed::Request;
use LWP::UserAgent;

sub new {
  my ($class, $config) = @_;
  my $self = bless {
    config    => $config,
    providers => [],
    shorturls => [],
  }, $class;

  $self->load_providers;

  return $self;
}

sub cache {
  my $self = shift;

  $self->{cache} ||= Cache::Memcached->new(
    servers => ["127.0.0.1:11211"],
    debug   => 0,
  );
  $self->{cache};
}

sub render {
  my $self = shift;
  my $template = $self->template;
  $self->{render} ||= sub {
    $template->render_file(@_)->as_string;
  };
}

sub load_providers {
  my $self = shift;
  $self->load_provider($_) for Module::Find::findsubmod("Noembed::Provider");
}

sub load_provider {
  my ($self, $class) = @_;

  my ($success, $error) = Class::Load::try_load_class($class);
  if (!$success) {
    warn "Could not load provider $class: $_";
    return;
  }

  my $provider = eval {
    $class->new(
      render => $self->render,
      image_prefix => $self->config->{image_prefix},
      share_dir => $self->config->{share_dir},
    )
  };
  if ($@) {
    warn "Could not initialize provider $class, disabling: $@";
    return;
  }
  push @{ $self->{providers} }, $provider;
  push @{ $self->{shorturls} }, map {qr{$_}} $provider->shorturls;
}

sub template {
  my $self = shift;
  $self->{template} ||= Text::MicroTemplate::File->new(
    include_path => [ $self->config->{share_dir} . "/templates" ],
    use_cache    => 2
  );
}

sub handle_request {
  my ($self, $req) = @_;
  my $res = eval { $self->handle_url($req) };
  if (my $error = $@) {
    return error_res($error, $req);
  }

  return $res;
}

sub handle_url {
  my ($self, $req) = @_;

  die "url parameter is required" unless $req->url;

  if ($self->is_shorturl($req->url)) {
    my $redirect = $last_url = $req->url;
    my $redirects = 0;

    do {
      $last_url = $redirect;
      $redirect = Noembed::Util->http_resolve($redirect);
    } while ($redirects++ < 7 and $last_url ne $redirect);

    $req->url($redirect);
  }
 
  if (my $provider = $self->find_provider($req)) {
    return $self->download($provider, $req);
  }

  die "no matching providers found";
}

sub download {
  my ($self, $provider, $req) = @_;
  my $url = $provider->request_url($req);
  my $res;

  if (my $cache = $self->cache->get($url)) {
    warn "cache hit for $url";
    $res = thaw($cache);
  }
  else {
    $res = Noembed::Util->http_get($url);
    $self->cache->set($url, freeze($res));
  }

  if ($res->code == 200) {
    my $data = $provider->finalize($req, $res);
    return json_res(
      $data,
      "surrogate-key" => lc $provider->provider_name,
      "surrogate-control" => 60 * 60 * 24 * 100,
    );
  }
  elsif ($res->code =~ /^40[0-9]$/) {
    return json_res(
      {
        error => $res->status_line,
        url   => $req->url,
      },
      "surrogate-key" => lc $provider->provider_name,
      "surrogate-control" => 60 * 30,
    );
  }
  else {
    warn "error processing " . $req->url. " : ". $res->status_line;
    die $res->status_line;
  }
}

sub error_res{
  my ($message, $req) = @_;

  $message =~ s/at .+?\.pm line.+//;

  return json_res({
    error => ($message || "unknown error"),
    url   => $req->url,
  }, 'Cache-Control', 'no-cache');
}

sub json_res{
  my ($data, @headers) = @_;
  my $body = JSON::XS::encode_json $data;

  [
    200,
    [
      @headers,
      'Content-Type', 'text/javascript; charset=utf-8',
      'Content-Length', length $body
    ],
    [$body]
  ];
}

sub providers_response {
  my ($self, $env) = @_;
  my $providers = [ map {
    +{
      name     => $_->provider_name,
      patterns => [$_->patterns, $_->shorturls],
    }
  } @{$self->{providers}} ];

  return json_res($providers, "surrogate-key" => "providers");
}

sub is_shorturl {
  my ($self, $url) = @_;

  for my $re (@{$self->{shorturls}}) {
    return 1 if $url =~ $re;
  }

  return 0;
}

sub find_provider {
  my ($self, $req) = @_;

  for my $provider (@{$self->{providers}}) {
    return $provider if $provider->matches($req);
  }

  return ();
}

sub config {
  my $self = shift;
  $self->{config};
}

1;

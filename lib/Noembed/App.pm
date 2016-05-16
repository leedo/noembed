package Noembed::App;

use Module::Find ();
use Class::Load;
use Text::MicroTemplate::File;
use JSON::XS;

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

  my $res = Noembed::Util->http_get($url);

  if ($res->code == 200) {
    my $data = $provider->finalize($req, $res);

    $data->{html} = $self->render->("inner-wrapper.html", $provider, $data);
    unless ($req->parameters->{nowrap}) {
      $data->{html} = $self->render->("wrapper.html", $provider, $data);
    }
    my @headers = ("Surrogate-Key", $provider->surrogate_key);
    return json_res($data, @headers);
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

sub css_response {
  my ($self, $env) = @_;
  my $css = join "\n", map {
    my $file = $self->config->{share_dir} . "/styles/" . $_;
    if (-r $file) {
      open my $fh, "<", $file;
      local $/;
      <$fh>;
    }
    else {
      "";
    }
  } "wrapper.css", map {$_->filename("css")} @{$self->{providers}};

  return [
    200,
    [ "Content-Type" => "text/css",
      "Content-Length" => length($css) ],
    [$css]
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

  return json_res($providers);
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

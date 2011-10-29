package Noembed;

use strict;
use warnings;

use Carp;
use Module::Find ();
use Class::Load;
use Text::MicroTemplate::File;
use File::ShareDir;
use AnyEvent::HTTP;
use Encode;
use JSON;
use AnyEvent::Strict;

use Noembed::Request;

use parent 'Plack::Component';

our $VERSION = "0.01";

sub prepare_app {
  my $self = shift;

  my $template = Text::MicroTemplate::File->new(
    include_path => [template_dir()],
    use_cache    => 2
  );

  $self->{render} = sub { $template->render_file(@_) };
  $self->{providers} = [];
  $self->{shorturls} = [
    qr{http://t\.co/[0-9a-zA-Z]+},
  ];
  $self->{locks} = {};

  if ($self->{sources} and ref $self->{sources} eq 'ARRAY') {
    $self->register_provider($_) for @{$self->{sources}};
    delete $self->{sources};
  }
  else {
    $self->register_provider($_) for Module::Find::findsubmod("Noembed::Source");
  }
}

sub call {
  my ($self, $env) = @_;

  my $req = Noembed::Request->new($env);
  return error("url parameter is required") unless $req->url;

  return sub {
    my $respond = shift;

    my $working = $self->has_lock($req->hash);
    $self->add_lock($req->hash, $respond);

    return if $working;
    return $self->handle_url($req);
  };
}

sub template_dir {
  return share_dir() . "/templates";
}

sub style_dir {
  return share_dir() . "/styles";
}

# yuck.
sub share_dir {
  my @try = ("share", "../share");
  for (@try) {
    return $_ if -e "$_/templates/Twitter.html";
  }
  File::ShareDir::dist_dir "Noembed";
}

sub handle_url {
  my ($self, $req, $times) = @_;

  $times = 1 unless defined $times;

  if ($times > 5) {
    return $self->end_lock($req->hash, error("Too many redirects for " . $req->url));
  }

  if ($self->is_shorturl($req->url)) {
    return $self->resolve($req, $times);
  }
 
  if (my $provider = $self->find_provider($req)) {
    return $self->download($provider, $req);
  }

  $self->end_lock($req->hash, error("no matching providers found for " . $req->url));
}

sub json_res {
  my $body = encode_json shift;

  [
    200,
    [
      'Content-Type', 'text/javascript; charset=utf-8',
      'Content-Length', length $body
    ],
    [$body]
  ];
}

sub error {
  json_res {error => ($_[0] || "unknown error")};
}

sub register_provider {
  my ($self, $class) = @_;

  if ($class !~ /^Noembed::Source::/ and $class !~ s/^\+//) {
    $class = "Noembed::Source::$class";
  }

  my ($loaded, $error) = Class::Load::try_load_class($class);
  if ($loaded) {
    my $provider = $class->new(render => $self->{render});
    push @{ $self->{providers} }, $provider;
    push @{ $self->{shorturls} }, map {qr{$_}} $provider->shorturls;
  }
  else {
    warn "Could not load provider $class: $error";
  }
}

sub download {
  my ($self, $provider, $req) = @_;

  my $service = $provider->request_url($req);
  my $nb = $req->env->{'psgi.nonblocking'};
  my $cv = AE::cv;

  http_request "get", $service, {
      persistent => 0,
      keepalive  => 0,
    },
    sub {
      my ($body, $headers) = @_;

      if ($headers->{Status} == 200) {
        eval {
          $body = decode("utf8", $body);
          $provider->post_download($body, sub {
            my $body = shift;
            my $data = $provider->serialize($body, $req);
            $self->end_lock($req->hash, json_res $data);
          });
        };
        if ($@) {
          my $error = $@;
          $error =~ s/at .+?\.pm line \d+\.//;
          $self->end_lock($req->hash, error($error));
        }
      }
      else {
        $self->end_lock($req->hash, error($headers->{Reason}));
      }

      $cv->send unless $nb;
    };

  $cv->recv unless $nb;
}

sub find_provider {
  my ($self, $req) = @_;

  for my $provider (@{$self->{providers}}) {
    return $provider if $provider->matches($req);
  }

  return ();
}

sub is_shorturl {
  my ($self, $url) = @_;

  for my $re (@{$self->{shorturls}}) {
    return 1 if $url =~ $re;
  }

  return 0;
}

sub resolve {
  my ($self, $req, $times) = @_;

  http_request get => $req->url,
    recurse => 0,
    sub {
      my ($body, $headers) = @_;

      if ($headers->{location}) {
        $req->url($headers->{location}) 
      }
      elsif ($body =~ /URL=([^"]+)"/) {
        $req->url($1);
      }

      $self->handle_url($req, $times + 1);
    };
}

sub providers_response {
  my ($self, $env) = @_;
  my $providers = [ map {
    +{
      name     => $_->provider_name,
      patterns => [$_->patterns, $_->shorturls],
    }
  } @{$self->{providers}} ];

  return json_res $providers; 
}

sub add_lock {
  my ($self, $key, $respond) = @_;

  $self->{locks}{$key} ||= [];
  push @{$self->{locks}{$key}}, $respond;
}

sub end_lock {
  my ($self, $key, $res) = @_;
  my $locks = delete $self->{locks}{$key};
  $_->([@$res]) for @$locks;
}

sub has_lock {
  my ($self, $key) = @_;
  exists $self->{locks}{$key} and @{$self->{locks}{$key}};
}

1;

=pod

=head1 NAME

Noembed - oembed gateway

=head1 SYNOPSIS

    use Plack::Builder;
    use Noembed;

    builder {
      mount "/oembed" => builder {
        enable JSONP;
        Noembed->new->to_app;
      };
    };

=head1 DESCRIPTION

Noembed is an oEmbed gateway. It lets you fetch information about
external URLs, which you can then use to embed into HTML pages.
Noembed can fetch information about a large list of URLs, and it
is very easy to define new types of URLs.

To add a new set of URLs to Noembed you create a new class that
inherits from L<Noembed::Source> and override a few methods.

=head1 CUSTOM SOURCES

Use the C<sources> option to load a custom list of source classes.
All classes are assumed to be under the Noembed::Source namespace
unless prefixed with C<+>.

    # only load YouTube and a custom source
    my $noembed = Noembed->new(
      sources => [qw/ YouTube +My::Custom::Source /]
    );

    builder {
      mount "/oembed" => $noembed->to_app;
    };

=head1 EXAMPLES

To see an example of how to use Noembed from the client side, take
a look at the demo in the eg/ directory. It accepts a URL and
attempts to embed it in the page.

=head1 AUTHOR

Lee Aylward

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

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
  return $self->handle_url($req);
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
  my ($self, $req) = @_;

  return sub {
    my $respond = shift;

    my $url = $req->url;
    my $working = $self->has_lock($url);
    $self->add_lock($url, $respond);
    return if $working;
  
    for my $provider (@{$self->{providers}}) {
      if ($provider->matches($req)) {
        return $self->download($provider, $req);
      }
    }

    $self->end_lock($url, error("no matching providers found for $url"));
  }
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
          my $data = $provider->serialize($body, $req);
          $self->end_lock($req->url, json_res $data);
        };
        carp "Error after http request: $@" if $@;
      }
      else {
        $self->end_lock($req->url, error($headers->{Reason}));
      }

      $cv->send unless $nb;
    };

  $cv->recv unless $nb;
}

sub providers_response {
  my ($self, $env) = @_;
  my $providers = [ map {
    +{
      name     => $_->provider_name,
      patterns => [$_->patterns],
    }
  } @{$self->{providers}} ];

  return json_res $providers; 
}

sub add_lock {
  my ($self, $url, $respond) = @_;

  $self->{locks}{$url} ||= [];
  push @{$self->{locks}{$url}}, $respond;
}

sub end_lock {
  my ($self, $url, $res) = @_;
  my $locks = delete $self->{locks}{$url};
  $_->([@$res]) for @$locks;
}

sub has_lock {
  my ($self, $url) = @_;
  exists $self->{locks}{$url} and @{$self->{locks}{$url}};
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

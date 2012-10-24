package Noembed;

use strict;
use warnings;

use Carp;
use Module::Find ();
use Try::Tiny;
use Class::Load;
use Text::MicroTemplate::File;
use File::ShareDir;

use Noembed::Util;
use Noembed::Request;

use parent 'Plack::Component';

our $VERSION = "0.01";
our $SHAREDIR = "share";

sub prepare_app {
  my $self = shift;

  my $template = Text::MicroTemplate::File->new(
    include_path => [template_dir()],
    use_cache    => 2
  );

  $self->{render} = sub { $template->render_file(@_)->as_string };
  $self->{providers} = [];
  $self->{shorturls} = [];

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

  return sub {
    my $respond = shift;
    my $req = Noembed::Request->new($env, $respond);
    return $req->error("url parameter is required") unless $req->url;
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
  my @try = ($SHAREDIR, "../$SHAREDIR");
  for (@try) {
    return $_ if -e "$_/templates/Twitter.html";
  }
  File::ShareDir::dist_dir "Noembed";
}

sub handle_url {
  my ($self, $req, $times) = @_;

  $times = 1 unless defined $times;

  if ($times > 5) {
    return $req->error("Too many redirects");
  }

  if ($self->is_shorturl($req->url)) {
    return Noembed::Util::http_resolve $req->url, sub {
      $req->url(shift);
      $self->handle_url($req, $times + 1);
    };
  }
 
  if (my $provider = $self->find_provider($req)) {
    return $provider->pre_download($req, sub {
      $req = shift;
      $self->download($provider, $req);
    });
  }

  $req->error("no matching providers found");
}

sub register_provider {
  my ($self, $class) = @_;

  if ($class !~ /^Noembed::Source::/) {
    $class = "Noembed::Source::$class";
  }

  try {
    Class::Load::load_class($class);
    my $provider = $class->new(render => $self->{render});
    push @{ $self->{providers} }, $provider;
    push @{ $self->{shorturls} }, map {qr{$_}} $provider->shorturls;
  } catch {
    warn "Could not load provider $class: $_";
  };
}

sub download {
  my ($self, $provider, $req) = @_;
  my $service = $provider->request_url($req);

  Noembed::Util::http_get $service, sub {
    my ($body, $headers) = @_;

    if ($headers->{Status} == 200) {
      eval {
        $provider->post_download($body, $req, sub {
          $body = shift;
          my $data = $provider->finalize($body, $req);
          $data->{html} = $self->{render}->("inner-wrapper.html", $provider, $data);
          unless ($req->parameters->{nowrap}) {
            $data->{html} = $self->{render}->("wrapper.html", $provider, $data);
          }
          $req->respond(Noembed::Util::json_res $data);
        });
      };
      if ($@) {
        my $error = $@;
        warn "error processing $service: $error\n";
        $error =~ s/at .+?\.pm line.+//;
        $req->error($error);
      }
    }
    else {
      warn "error processing $service: $headers->{Status} $headers->{Reason}";
      $req->error($headers->{Reason});
    }
  };
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

sub providers_response {
  my ($self, $env) = @_;
  my $providers = [ map {
    +{
      name     => $_->provider_name,
      patterns => [$_->patterns, $_->shorturls],
    }
  } @{$self->{providers}} ];

  return Noembed::Util::json_res $providers; 
}

sub css_response {
  my ($self, $env) = @_;
  $self->{css} ||= join "\n", map {
    my $file = style_dir() . "/" . $_;
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
      "Content-Length" => length($self->{css}) ],
    [$self->{css}]
  ];
}

1;

=pod

=head1 NAME

Noembed - extendable oEmbed gateway

=head1 SYNOPSIS

    use Plack::Builder;
    use Noembed;

    my $noembed = Noembed->new;

    builder {

      # an oEmbed endpoint supporting lots of sites
      mount "/embed" => builder {
        enable "JSONP";
        $noembed->to_app;
      };

      # a CSS file with all the styles
      mount "/noembed.css" => $noembed->css_response;

      # a JSON response describing all the supported sites
      # and what URL patterns they match
      mount "/providers" => $noembed->providers_response;
    };

=head1 DESCRIPTION

Noembed is an oEmbed gateway. It allows you to fetch information
about external URLs, which can then be embeded HTML pages. Noembed
supports a large list of sites and makes it easy to add more.

To add a new site to Noembed create a new class that inherits from
L<Noembed::Source>, L<Noembed::ImageSource>, or L<Noembed::oEmbedSource>
and override the required methods.

=head1 EXAMPLES

To see an example of how to use Noembed from the client side, take
a look at the demo in the eg/ directory. It accepts a URL and
attempts to embed it in the page.

=head1 SEE ALSO

L<Noembed::Source>, L<Noembed::ImageSource>, L<Noembed::oEmbedSource>,
L<Noembed::Util>, L<Web::Scraper>

=head1 AUTHOR

Lee Aylward

=head1 CONTRIBUTORS

=over 4

=item * Clint Ecker (Path support)

=item * Ryan Baumann (Spotify support)

=item * Bryce Kerley (Spelling fixes, Facebook and Twitter API help)

=item * Cameron Johnston (Instagram fix)

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

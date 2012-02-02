package Noembed::Source::AppleTrailers;

use parent 'Noembed::Source';

use Web::Scraper;
use AnyEvent::HTTP;

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'title', title => 'HTML';
    process 'a.movieLink', src => '@href';
  };
}

sub provider_name { "iTunes Movie Trailers" }
sub patterns { 'http://trailers\.apple\.com/trailers/[^/]+/[^/]+' }

sub post_download {
  my ($self, $body, $callback) = @_;

  my $data = $self->{scraper}->scrape($body);
  die "can not find title" unless $data->{title};

  my ($path) = $body =~ /trailerURL\s*=\s*'([^']+)'/;
  die "can not find path" unless $path;

  my $url = "http://trailers.apple.com/$path/includes/trailer/large.html";
  http_request get => $url, {
      recurse => 0,
      persistent => 0
    },
    sub {
      my ($body, $headers) = @_;
      my $src = $self->{scraper}->scrape($body);
      die "can not find movie src" unless $src->{src};
      $data->{src} = $src->{src};
      $callback->($data);
    };
}

sub serialize {
  my ($self, $data, $req) = @_;
  my ($title) = $data->{title} =~ /(.+) - Movie Trailers/;
  return {
    title => $title,
    html => $self->render($data->{src}),
  }
}

1;

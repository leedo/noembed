package Noembed::Source::AppleTrailers;

use parent 'Noembed::Source';

use Web::Scraper;
use AnyEvent::HTTP;

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'title', title => 'HTML';
  };

  $self->{src_scraper} = scraper {
    process 'a.movieLink', src => '@href';
  };
}

sub provider_name { "Apple Trailer" }
sub patterns { 'http://trailers\.apple\.com/trailers/[^/]+/[^/]+' }

sub post_download {
  my ($self, $body, $callback) = @_;
  my $data = $self->{scraper}->scrape($body);
  my ($path) = $body =~ /trailerURL\s*=\s*'([^']+)'/;
  my $url = "http://trailers.apple.com/$path/includes/trailer/large.html";
  warn $url;
  http_request get => $url, {
      recurse => 0,
      persistent => 0
    },
    sub {
      my ($body, $headers) = @_;
      my $src_data = $self->{src_scraper}->scrape($body);
      $data->{src} = $src_data->{src};
      $callback->($data);
    };
}

sub serialize {
  my ($self, $data, $req) = @_;
  my ($title) =~ $data->{title} =~ /(.+) - Movie Trailer/;
  return {
    title => $title,
    html => $self->render($data->{src}),
  }
}

1;

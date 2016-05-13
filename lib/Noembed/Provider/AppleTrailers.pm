package Noembed::Provider::AppleTrailers;

use parent 'Noembed::Provider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'title', title => 'HTML';
    process 'a.movieLink', src => '@href';
  };
}

sub provider_name { "iTunes Movie Trailers" }
sub patterns { 'http://trailers\.apple\.com/trailers/[^/]+/[^/]+' }

sub serialize {
  my ($self, $body, $req) = @_;

  my $data = $self->{scraper}->scrape($body);
  die "can not find title" unless $data->{title};

  my ($path) = $body =~ /trailerURL\s*=\s*'([^']+)'/;
  die "can not find path" unless $path;

  my $res = Noembed::Util->http_get($url);
  my $src = $self->{scraper}->scrape($res->decoded_content);
  die "can not find movie src" unless $src->{src};
  $data->{src} = $src->{src};

  my $url = "http://trailers.apple.com/$path/includes/trailer/large.html";

  my ($title) = $data->{title} =~ /(.+) - Movie Trailers/;
  return {
    title => $title,
    html => $self->render($data->{src}),
  }
}

1;

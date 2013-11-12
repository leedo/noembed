package Noembed::Provider::IMDB;

use JSON;
use URI;
use URI::QueryParam;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{tmdb_key} = "c9bf8bd5df7a72877bc39a297c9b859a";
  $self->{tmdb_url} = "http://api.themoviedb.org/3";
}

sub patterns { 'http://(?:www\.)?imdb.com/title/(tt\d+)' }
sub provider_name { 'IMDB' }

sub build_url {
  my ($self, $req) = @_;
  my $id = $req->captures->[0];
  my $uri = URI->new("$self->{tmdb_url}/movie/$id");
  $uri->query_param(api_key => $self->{tmdb_key});
  return $uri;
}

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  my $movie = from_json $body;

  return $cb->($movie) unless $movie->{poster_path};

  my $uri = URI->new("$self->{tmdb_url}/configuration");
  $uri->query_param(api_key => $self->{tmdb_key});

  $req->http_get($uri->as_string, sub {
    my ($body, $headers) = @_;
    my $config = from_json $body;
    $movie->{poster} = URI->new(join "/", (
      $config->{images}{base_url},
      $config->{images}{poster_sizes}[0],
      $movie->{poster_path},
    ))->as_string;
    $movie->{url} = $req->url;
    $cb->($movie);
  });
}

sub serialize {
  my ($self, $movie, $req) = @_;

  ($movie->{year}) = split "-", $movie->{release_date};

  return +{
    title => "$movie->{name} ($movie->{year})",
    html => $self->render($movie, $poster),
  };
}

1;

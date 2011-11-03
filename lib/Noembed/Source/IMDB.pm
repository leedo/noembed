package Noembed::Source::IMDB;

use JSON;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{tmdb_key} = "c9bf8bd5df7a72877bc39a297c9b859a";
  $self->{tmdb_url} = "http://api.themoviedb.org/2.1";
}

sub patterns { 'http://(?:www\.)?imdb.com/title/(tt\d+)' }
sub provider_name { 'IMDB' }

sub request_url {
  my ($self, $req) = @_;
  my $id = $req->captures->[0];
  return "$self->{tmdb_url}/Movie.imdbLookup/en/json/$self->{tmdb_key}/$id";
}

sub serialize {
  my ($self, $body) = @_;
  my $data = decode_json $body;
  my ($movie) = @{$data};

  die "invalid movie id" unless $movie and $movie ne "Nothing found.";

  ($movie->{year}) = split "-", $movie->{released};

  return +{
    title => "$movie->{name} ($movie->{year})",
    html => $self->render($movie),
  };
}

1;

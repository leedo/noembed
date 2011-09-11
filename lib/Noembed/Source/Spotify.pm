package Noembed::Source::Spotify;

use Web::Scraper;
use Text::MicroTemplate qw/encoded_string/;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process 'title', title => 'TEXT';
    process '#title', track => 'RAW';
    process '#artist .meta-info', artist => 'RAW';
    process '#album .meta-info', album => 'RAW';
    process '#cover-art', coverart => '@src';
  };
}

sub patterns { 'https?://open\.spotify\.com/track/(\w{22})' }
sub provider_name { "Spotify" }

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);
  $data->{$_} = encoded_string $data->{$_} for qw/track artist album/;
  $data->{title} =~ s/ on Spotify//;

  return +{
    title => $data->{title},
    html  => $self->render($data),
  };
}

1;

package Noembed::Source::Twitpic;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process "#photo-display", image => '@src';
    process "#view-photo-caption", caption => 'TEXT';
  };
}

sub pattern { 'http://(www\.)?twitpic\.com/.+' }
sub provider_name { "Twitpic" }

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  $data->{caption} =~ s/^\s+//ms;
  $data->{caption} =~ s/\s+$//ms;

  return +{
    html  => $self->render($data),
    title => $data->{caption},
  };
}

1;

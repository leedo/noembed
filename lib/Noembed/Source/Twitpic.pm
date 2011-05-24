package Noembed::Source::Twitpic;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{re} = qr{http://(www\.)?twitpic\.com/.+}i;
  $self->{scraper} = scraper {
    process "#photo-display", image => '@src';
    process "#view-photo-caption", caption => 'TEXT';
  };
}

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  $data->{caption} =~ s/^\s+//ms;
  $data->{caption} =~ s/\s+$//ms;

  return +{
    html => '<a href="'.$data->{image}.'"><img src="'.$data->{image}.'"></a>',
    title => $data->{caption},
  };
}

sub provider_name { "Twitpic" }

1;

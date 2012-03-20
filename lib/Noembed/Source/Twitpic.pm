package Noembed::Source::Twitpic;

use Web::Scraper;
use parent 'Noembed::ImageSource';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process "#media > img", src => '@src';
    process "#media-caption > p", title => 'TEXT';
  };
}

sub patterns { 'http://(www\.)?twitpic\.com/.+' }
sub provider_name { "Twitpic" }

sub image_data {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  unless ($data->{src}) {
    die "no image";
  }

  $data->{title} =~ s/^\s+//ms;
  $data->{title} =~ s/\s+$//ms;

  if (!$data->{title}) {
    ($data->{title}) = $data->{src} =~ /\/([^\/]+\.(?:jpg|gif|png))/;
  }

  return $data;
}

1;

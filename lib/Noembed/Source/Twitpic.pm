package Noembed::Source::Twitpic;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{scraper} = scraper {
    process "#media > img", image => '@src';
    process "#media-caption > p", caption => 'TEXT';
  };
}

sub patterns { 'http://(www\.)?twitpic\.com/.+' }
sub provider_name { "Twitpic" }

sub serialize {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  unless ($data->{image}) {
    die "no image";
  }

  $data->{caption} =~ s/^\s+//ms;
  $data->{caption} =~ s/\s+$//ms;

  if (!$data->{caption}) {
    ($data->{caption}) = $data->{image} =~ /\/([^\/]+\.(?:jpg|gif|png))/;
  }

  return +{
    html  => $self->render($data),
    title => $data->{caption},
  };
}

1;

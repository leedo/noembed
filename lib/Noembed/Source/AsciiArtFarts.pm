package Noembed::Source::AsciiArtFarts;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'td[bgcolor="#000000"] font', html => 'RAW';
    process 'h1', title => 'TEXT';
  };
}

sub patterns { 'http://www\.asciiartfarts\.com/[0-9]+\.html' }
sub provider_name { "ASCII Art Farts" }

sub filter {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  return +{
    html => "<div class=\"ascii-fart-embed\">$data->{html}</div>",
    title => $data->{title},
  };
}

1;

package Noembed::Source::Bash;

use Web::Scraper;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process "p.qt", quote => "RAW";
  };
}

sub provider_name { "Bash.org" }
sub patterns { 'http://bash\.org/\?(\d+)' }

sub serialize {
  my ($self, $body, $req) = @_;

  my $number = $req->captures->[0];
  my $data = $self->{scraper}->scrape($body);

  return +{
    title => "Quote #$number",
    html => $self->render(encoded_string $data->{quote}),
  };
}

1;

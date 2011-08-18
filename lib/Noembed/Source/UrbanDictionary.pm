package Noembed::Source::UrbanDictionary;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{http://(?:www\.)urbandictionary\.com/define\.php\?term=.+}i;
  $self->{scraper} = scraper {
    process "td.word", "words[]" => "TEXT";
    process "div.definition", "definitions[]" => "HTML";
  };
}

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub filter {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  my $title = $data->{words}->[0];
  $title =~ s/^\s//ms;
  $title =~ s/\s+$//ms;

  return +{
    title => $title,
    html  => $self->render($data),
  }
}

sub provider_name { "Urban Dictionary" }

1;

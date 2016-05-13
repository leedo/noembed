package Noembed::Provider::UrbanDictionary;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process "div.word a", "words[]" => "TEXT";
    process "div.meaning", "definitions[]" => "HTML";
  };
}

sub patterns { 'http://www\.urbandictionary\.com/define\.php\?term=.+' }
sub provider_name { "Urban Dictionary" }

sub serialize {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  if (!@{$data->{words}}) {
    die "term not found!";
  }

  my $title = $data->{words}->[0];
  $title =~ s/^\s//ms;
  $title =~ s/\s+$//ms;

  $data->{definitions} = [ map {Noembed::Util->clean_html($_)} @{$data->{definitions}} ];

  return +{
    title => $title,
    html  => $self->render($data),
  }
}

1;

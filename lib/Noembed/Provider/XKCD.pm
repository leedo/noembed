package Noembed::Provider::XKCD;

use parent 'Noembed::Provider';

use Web::Scraper;

sub prepare_provider {
  my $self = shift;

  $self->{scraper} = scraper {
    process '#comic > img, #comic > a > img', title => '@title';
    process '#comic > img, #comic > a > img', alt => '@alt';
    process '#comic > img, #comic > a > img', src => '@src';
  };
}

sub provider_name { "XKCD" }
sub patterns { 'http://(?:www\.)?xkcd\.com/\d+/?' }

sub serialize {
  my ($self, $body) = @_;

  my $data = $self->{scraper}->scrape($body);

  return {
    title => $data->{alt},
    html  => $self->render($data),
  }
}

1;

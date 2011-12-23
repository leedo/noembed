package Noembed::Source::Path;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'div.comment-body', title => 'TEXT';
    process 'img.photo-image', src => '@src';
  };
}

sub patterns { 'https?://path\.com/p/([0-9a-zA-Z]+)$' }
sub provider_name { "Path" }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  return +{
    html => $self->render($data),
    title => $data->{title} || "",
  }
}

1;

package Noembed::Source::Path;

use Web::Scraper;

use parent 'Noembed::ImageSource';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'div.comment-body', title => 'TEXT';
    process 'img.photo-image', src => '@src';
  };
}

sub patterns { 'https?://path\.com/p/([0-9a-zA-Z]+)$' }
sub provider_name { "Path" }

1;

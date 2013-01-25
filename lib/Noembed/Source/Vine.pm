package Noembed::Source::Vine;

use Web::Scraper;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'meta[property="twitter:player"]', src => '@content';
    process 'meta[property="twitter:player:width"]', width => '@content';
    process 'meta[property="twitter:player:height"]', height => '@content';
    process 'meta[property="twitter:description"]', desc => '@content';
    process 'meta[property="twitter:title"]', title => '@content';
  };
}

sub provider_name { "Vine" }
sub patterns { 'https?://vine.co/v/[a-zA-Z0-9]+' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  for (qw(src width height desc title)) {
    die "missing $_" unless defined $data->{$_};
  }

  return +{
    html => $self->render($data),
    title => join(": ", $data->{title}, $data->{desc}),
  };
}

1;

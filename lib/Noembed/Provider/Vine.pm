package Noembed::Provider::Vine;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'meta[property="twitter:description"]', desc => '@content';
    process 'meta[property="twitter:title"]', title => '@content';
  };
}

sub provider_name { "Vine" }
sub patterns { 'https?://vine.co/v/[a-zA-Z0-9]+' }

sub serialize {
  my ($self, $body, $req) = @_;
  my $data = $self->{scraper}->scrape($body);

  for (qw(desc title)) {
    die "missing $_" unless defined $data->{$_};
  }

  return +{
    html => $self->render($req->url),
    title => join(": ", $data->{title}, $data->{desc}),
  };
}

1;

package Noembed::Provider::Bash;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process "p.qt", quote => "HTML";
  };
}

sub provider_name { "Bash.org" }
sub patterns { 'http://bash\.org/\?(\d+)' }

sub serialize {
  my ($self, $body, $req) = @_;

  my $number = $req->captures->[0];
  my $data = $self->{scraper}->scrape($body);

  die "no quote" unless $data->{quote};

  return +{
    title => "Quote #$number",
    html => $self->render(Noembed::Util->html($data->{quote})),
  };
}

1;

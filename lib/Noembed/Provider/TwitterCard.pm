package Noembed::Provider::TwitterCard;

sub providers {
  my ($class, @args) = @_;

  my @cards = (
    ["The Onion", 'http://www\.theonion\.com/articles/[^/]+/?'],
  );

  my @providers;

  for my $card (@cards) {
    my ($name, @patterns) = @$card;

    my $package = $name;
    $package =~ s/[^a-zA-Z]//g;
    $package = "Noembed::Provider::$package";

    *{"$package\::provider_name"}     = sub { $name };
    *{"$package\::patterns"} = sub { @patterns };
    @{"$package\::ISA"} = "Noembed::TwitterCardProvider";

    push @providers, $package->new(@args);
  }

  return @providers;
}

package Noembed::TwitterCardProvider;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'meta[name="twitter:title"]', title => '@content';
    process 'meta[name="twitter:url"]', url => '@content';
    process 'meta[name="twitter:description"]', description => '@content';
    process 'meta[name="twitter:image"]', image => '@content';
    process 'meta[name="twitter:card"]', card => '@content';
  };
}

sub filename {
  my ($self, $ext) = @_;
  return $ext ? "TwitterCard.$ext" : "TwitterCard";
}

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);

  for (qw/title url description card/) {
    die "missing $_" unless defined $data->{$_};
  }

  die "only support summary Twitter card type"
    unless $data->{card} eq "summary";

  +{
    title => $data->{title},
    html => $self->render($data),
  };
}

1;

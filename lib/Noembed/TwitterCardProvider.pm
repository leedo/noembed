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
  return "TwitterCard" unless $ext;
  return "TwitterCard.$ext" if $ext ne "png";
  return $self->SUPER::filename($ext);
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
    (defined $data->{image} ? ("image", $data->{image}) : ()),
  };
}

1;

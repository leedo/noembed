package Noembed::TwitterCardProvider;

use Web::Scraper;

use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;
  $self->{scraper} = scraper {
    process 'meta[name="twitter:title"]', title => '@content';
    process 'meta[property="og:title"]', og_title => '@content';
    process 'meta[name="twitter:url"]', url => '@content';
    process 'meta[property="og:url"]', og_url => '@content';
    process 'meta[name="twitter:description"]', description => '@content';
    process 'meta[property="og:description"]', og_description => '@content';
    process 'meta[name="twitter:image"]', image => '@content';
    process 'meta[name="twitter:image:src"]', "image:src" => '@content';
    process 'meta[property="og:image"]', og_image => '@content';
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
    if (!defined $data->{$_}) {
      if (defined $data->{"og_$_"}) {
        $data->{$_} = $data->{"og_$_"};
      }
      else {
        die "missing $_" unless defined $data->{$_};
      }
    }
  }

  for (qw{image image:src og_image}) {
    if (defined $data->{$_}) {
      $data->{image} = $data->{$_};
      last;
    }
  }

  die "only support summary Twitter card type"
    unless $data->{card} =~ /^summary/;

  +{
    html => $self->render($data),
    # include original metadata
    map {$_ => $data->{$_}} grep {defined $data->{$_}} qw/title url description image/,
  };
}

1;

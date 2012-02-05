package Noembed::ImageSource;

use parent 'Noembed::Source';

sub post_download {
  my ($self, $body, $req, $cb) = @_;

  my $data = $self->{scraper}->scrape($body);
  die "No image found" unless $data->{src};

  Noembed::Util::dimensions $data->{src}, $req, sub {
    my ($w, $h) = @_;
    $data->{width} = $w;
    $data->{height} = $h;
    $cb->($data);
  }
}

sub serialize {
  my ($self, $data, $req) = @_;

  return +{
    title => $data->{title} || $req->url,
    html => $self->render($data, $req->url),
  }
}

sub render {
  my $self = shift;
  my $id = Data::GUID->new->as_string;
  $self->{render}->("ImageSource.html", $id, @_);
}

1;

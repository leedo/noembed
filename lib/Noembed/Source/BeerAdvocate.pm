package Noembed::Source::BeerAdvocate;

use Web::Scraper;
use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  my $base = "http://beeradvocate.com";

  $self->{re} = qr{http://(?:www\.)?beeradvocate\.com/beer/profile/\d+/\d+}i;
  $self->{scraper} = scraper {
    process "td#mainContent > h1", title => 'TEXT';
    process "//table[id('mainContent')]//table[1]", html => sub {
      my $e = shift;

      for my $a ($e->look_down(_tag => "a", class => "twitter-share-button")) {
        my ($div) = $a->look_up(_tag => "div");
        $div->left->destroy;
        $div->left->destroy;
        $div->destroy;
      }

      for my $a ($e->find("a")) {
        my $href = $a->attr("href");
        $a->attr(href => $base.$href);
        $a->attr(target => "_blank");
      }

      for my $img ($e->find("img")) {
        my $src = $img->attr("src");
        $img->attr(src => $base.$src);
      }

      $e->as_HTML;
    };
  };
}

sub provider_name { "Beer Advocate" }

sub matches {
  my ($self, $url) = @_;
  $url =~ $self->{re};
}

sub filter {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  +{
    title => $data->{title},
    html => _css().'<div class="beer-advocate-embed">'.$data->{html}.'</div>',
  };
}

sub _css {
'<style type="text/css">
  div.beer-advocate-embed {
    border: 1px solid #ccc;
    padding: 5px;
  }
  div.beer-advocate-embed table td {
    font-size: 12px;
  }
</style>';
}

1;

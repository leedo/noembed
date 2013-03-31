package Noembed::Provider::BeerAdvocate;

use Web::Scraper;
use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;

  my $base = "http://beeradvocate.com";

  $self->{scraper} = scraper {
    process "td#mainContent > h1", title => 'TEXT';
    process "div#baContent > table", html => sub {
      my $e = shift;

      for my $a ($e->look_down(_tag => "a", class => "twitter-share-button")) {
        my ($div) = $a->look_up(_tag => "div");
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

      clean_html($e->as_HTML);
    };
  };
}

sub provider_name { "Beer Advocate" }
sub patterns { 'http://(?:www\.)?beeradvocate\.com/beer/profile/\d+/\d+' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  $data->{html} =~ s/<br[^>]*>\s*Displayed[^\.]+\.//s;
  +{
    title => $data->{title},
    html => "<div class=\"beer-advocate-embed\">$data->{html}</div>",
  };
}

1;

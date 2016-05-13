package Noembed::Provider::BeerAdvocate;

use Web::Scraper;
use parent 'Noembed::Provider';

sub prepare_provider {
  my $self = shift;

  my $base = "http://beeradvocate.com";

  $self->{scraper} = scraper {
    process 'meta[property="og:title"]', title => '@content';
    process "div#baContent > table", html => sub {
      my $e = shift;

      for my $a ($e->look_down(_tag => "a", class => "twitter-share-button")) {
        my ($div) = $a->look_up(_tag => "div");
        $div->left->destroy;
        $div->destroy;
      }

      for my $a ($e->find("a")) {
        my $href = $a->attr("href");
        if ($href !~ m{^(https?:)?//}) {
          $a->attr(href => $base.$href);
        }
        $a->attr(target => "_blank");
      }

      for my $img ($e->find("img")) {
        my $src = $img->attr("src");
        if ($src !~ m{^(https?:)?//}) {
          $img->attr(src => $base.$src);
        }
      }

      Noembed::Util->clean_html($e->as_HTML);
    };
  };
}

sub provider_name { "Beer Advocate" }
sub patterns { 'http://(?:www\.)?beeradvocate\.com/beer/profile/\d+/\d+' }

sub serialize {
  my ($self, $body) = @_;
  my $data = $self->{scraper}->scrape($body);
  $data->{title} =~ s/ - BeerAdvocate$//;
  $data->{html} =~ s/<br[^>]*>\s*Displayed[^\.]+\.//s;
  +{
    title => $data->{title},
    html => "<div class=\"beer-advocate-embed\">$data->{html}</div>",
  };
}

1;

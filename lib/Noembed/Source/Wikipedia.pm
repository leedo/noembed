package Noembed::Source::Wikipedia;

use Web::Scraper;
use JSON;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{re} = qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i;
  $self->{scraper} = scraper {
    process "#firstHeading", title => 'TEXT';
    process "#bodyContent", html => sub {
      my $el = shift;
      my $output;
      my @children = $el->content_list;
      for my $child (@children) {
        last if $child->attr("id") eq "toc";
        if ($child->tag eq "p") {
          for my $a ($child->find("a")) {
            my $href = $a->attr("href");
            $a->attr("href", "http://www.wikipedia.org/$href");
          }
          $output .= $child->as_HTML;
        }
      }
      return $output;
    };
  };
}

sub provider_name { "Wikipedia" }

sub filter {
  my ($self, $body) = @_;

  my $res = $self->{scraper}->scrape($body);
  return $res;
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

1;

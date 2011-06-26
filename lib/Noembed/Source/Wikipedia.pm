package Noembed::Source::Wikipedia;

use Web::Scraper;
use List::MoreUtils qw/any/;
use JSON;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;

  $self->{re} = qr{http://[^\.]+\.wikipedia\.org/wiki/.*}i;
  $self->{scraper} = scraper {
    process "#firstHeading", title => 'TEXT';
    process "#bodyContent", html => \&_extract_content;
  };
}

sub _extract_content {
  my $el = shift;

  my ($image) = $el->look_down(class => "fullImageLink");
  if ($image) {
    my ($img) = $image->find("img");
    if ($img) {
      return '<a href="'.$img->attr("src").'" target="_blank">'.$img->as_HTML.'</a>';
    }
  }

  return _extract_text_content($el);
}

sub _extract_text_content {
  my $el = shift;
  my $output;
  my @children = $el->content_list;

  for my $child (@children) {
    my $tag = $child->tag;

    # stop once we hit the toc or a sub-head
    last if $child->attr("id") eq "toc"
         or $tag eq "h2";

    if (any {$tag eq $_} qw/p ul li/) {

      # fix the links
      for my $a ($child->find("a")) {
        my $href = $a->attr("href");
        $a->attr("target", "_blank");
        $a->attr("href", "http://www.wikipedia.org/$href");
      }

      $output .= $child->as_HTML;
    }
  }

  return "<div class='wikipedia-embed'>$output</div>";
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

sub style {
  $self->{style} ||= do {
    local $/;
    <DATA>
  };
}

1;

__DATA__
div.wikipedia-embed {
  border: 1px solid #ccc;
  font-size: 12px;
  padding: 5px;
}

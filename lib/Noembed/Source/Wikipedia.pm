package Noembed::Source::Wikipedia;

use HTML::TreeBuilder::XPath;
use List::MoreUtils qw/any/;
use Text::MicroTemplate qw/encoded_string/;

use parent 'Noembed::Source';

sub patterns { 'https?://[^\.]+\.wikipedia\.org/wiki/[^#]+(?:#(.+))?' }
sub provider_name { "Wikipedia" }

sub serialize {
  my ($self, $body, $req) = @_;
  my $tree = HTML::TreeBuilder::XPath->new;
  $tree->parse($body);
  my $title = $tree->findvalue('//h1[@id="firstHeading"]');
  my $html;

  if (my $img = $tree->findvalue('//div[@class="fullImageLink"]//img/@src')) {
    $html = $self->render(image => $img);
  }

  elsif (my $id = $req->captures->[0]) {
    my $start = $tree->findnodes('//span[@id="'.$id.'"]/parent::*/following-sibling::*')->[0];
    if ($start) {
      $title .= ": " . $tree->findvalue('//span[@id="'.$id.'"]');
      $html = $self->extract_text_content($start);
    }
  }

  if (!$html) {
    my $start = $tree->findnodes('//div[@class="mw-content-ltr"]/p')->[0];
    $html = $self->extract_text_content($start);
  }

  return +{
    title => $title,
    html  => $html,
  };
}

sub extract_text_content {
  my ($self, $el) = @_;
  my $output;

  while ($el) {
    my $tag = $el->tag;

    # stop once we hit the toc or a sub-head
    last if $el->attr("id") eq "toc"
         or $tag eq "h2";

    if (any {$tag eq $_} qw/p ul li/) {

      # fix the links
      for my $a ($el->find("a")) {
        my $href = $a->attr("href");
        $a->attr("target", "_blank");
        $a->attr("href", "http://www.wikipedia.org/$href");
      }

      $output .= $el->as_HTML;
    }
    $el = $el->right;
  }

  return $self->render(summary => encoded_string $output);
}

1;

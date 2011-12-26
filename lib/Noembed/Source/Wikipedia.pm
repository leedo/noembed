package Noembed::Source::Wikipedia;

use HTML::TreeBuilder;
use List::MoreUtils qw/any/;

use parent 'Noembed::Source';

sub patterns { 'https?://[^\.]+\.wikipedia\.org/wiki/[^#]+(?:#(.+))?' }
sub provider_name { "Wikipedia" }

sub serialize {
  my ($self, $body, $req) = @_;

  my $root = HTML::TreeBuilder->new_from_content($body)->elementify;

  my $title = $root->look_down(id => "firstHeading")->as_text;
  my $html;

  if ($req->url =~ m{/wiki/File:.+(?:gif|jpg|png|svg)}i) {
    my $container = $root->look_down(class => "fullImageLink");
    my $img = $container->find("img");
    $html = $self->render(image => $img->attr("src"));
  }
  elsif (my $id = $req->captures->[0]) {
    my $heading = $root->look_down(id => $id);
    if ($heading) {
      my $start = $heading->parent->right;
      $title .= ": " . $heading->as_text;
      $html = $self->extract_text_content($start, sub {
        $_[0]->tag eq $heading->parent->tag;
      })
    }
  }

  if (!$html) {
    my $start = $root->look_down(class => "mw-content-ltr")->find("p");
    $html = $self->extract_text_content($start, sub {
      $_[0]->tag eq "h2" or $_[0]->attr("class") eq "toc";
    });
  }

  return +{
    title => $title,
    html  => $html,
  };
}

sub extract_text_content {
  my ($self, $el, $stop) = @_;
  my $output;

  $_->destroy for $el->parent->look_down(class => "editsection");

  while ($el) {
    # stop once we hit the stop tag
    last if $stop->($el);

    if (any {$el->tag eq $_} qw/p ul li h2 h3 h4 div/) {

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

  return $self->render(summary => html($output));
}

1;

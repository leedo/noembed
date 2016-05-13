package Noembed::Provider::Wikipedia;

use HTML::TreeBuilder;
use List::Util qw/first/;

use parent 'Noembed::Provider';

sub patterns { 'https?://[^\.]+\.wikipedia\.org/wiki/(?!Talk:)[^#]+(?:#(.+))?' }
sub provider_name { "Wikipedia" }

sub serialize {
  my ($self, $body, $req) = @_;

  my $root = HTML::TreeBuilder->new_from_content(\$body)->elementify;

  my $title = $root->look_down(id => "firstHeading")->as_text;
  my $html;

  if ($req->url =~ m{/wiki/File:.+(?:gif|jpg|png|svg)}i) {
    my $container = $root->look_down(class => "fullImageLink");
    my $img = $container->find("img");
    $html = $self->render(image => $img->attr("src"));
  }
  elsif (my $id = $req->captures->[0]) {
    my $a = $root->look_down(id => $id);
    if ($a) {
      my $h = $a->parent;
      my $start = $h->right;
      $title .= ": " . $h->as_text;
      my $tag = $h->tag;
      my ($n) = $tag =~ /^h(\d+)$/i;
      my $stop_tag = $n ? qr{^h[1-\Q$n\E]$}i : qr{\Q$tag\E}i;
      $html = $self->extract_text_content($start, $req->url, sub {
        $_[0]->tag =~ $stop_tag;
      })
    }
  }

  if (!$html) {
    my $start = first {$_->tag eq "p"} $root->look_down(class => "mw-content-ltr")->content_list;
    $html = $self->extract_text_content($start, $req->url, sub {
      $_[0]->tag =~ /^(?:h2|h3)$/ or $_[0]->attr("class") eq "toc";
    });
  }

  $root->delete;

  return +{
    title => $title,
    html  => $html,
  };
}

sub extract_text_content {
  my ($self, $el, $url, $stop) = @_;
  my $output;
  my $badness = qr{editsection|tright|tleft|infobox|mainarticle|navbox|metadata};

  while ($el) {
    # stop once we hit the stop tag
    last if $stop->($el);

    # skip badness
    if ($el->attr('class') =~ $badness) {
      $el = $el->right;
      next;
    }

    # strip out badness
    $_->destroy for $el->look_down(sub {
      $_[0]->attr('class') =~ $badness;
    });

    # fix the links
    for my $a ($el->find("a")) {
      $a->attr("target", "_blank");
      my $href = $a->attr("href");
      my $prefix = $href =~ /^#/ ? $url : "http://www.wikipedia.org/";
      $a->attr("href", $prefix . $href);
    }

    $output .= $el->as_HTML;
    $el = $el->right;
  }

  return $self->render(summary => Noembed::Util->clean_html($output));
}

1;

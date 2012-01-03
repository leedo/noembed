package Noembed::Source::ArsComment;

use HTML::TreeBuilder;

use parent 'Noembed::Source';

sub patterns {'http://arstechnica\.com/[^#]+#comment-(\d+)'}
sub provider_name { "ArsTechnica Comment" }

sub serialize {
  my ($self, $body, $req) = @_;
  my $root = HTML::TreeBuilder->new_from_content($body)->elementify;
  my $id = $req->captures->[0];
  my $comment = $root->look_down("data-post-id" => $req->captures->[0]);

  die "could not find comment" unless $comment;

  my $title = $root->find("title")->as_text;
  my $link = $comment->look_down(href => "#comment-$id");
  $link->attr("href", $req->url);
  $link->attr("_target", "blank");
  $comment->attr($_, undef) for qw/id class data-post-id/;
  $comment->attr(class => "ars-comment-embed");

  return +{
    title => $title,
    html => $comment->as_HTML,
  }; 
}

1;

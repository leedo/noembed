package Noembed::Source::ArsTechnica;

use HTML::TreeBuilder;

use parent 'Noembed::Source';

sub patterns {
  'http://arstechnica\.com/[^#]+#comment-(\d+)',
  'http://arstechnica\.com/civis/viewtopic\.php\?(?:.+&)?p=(\d+)'
}
sub provider_name { "ArsTechnica" }
sub build_url {
  my ($self, $req) = @_;
  my $id = $req->captures->[0];
  return "http://arstechnica.com/civis/viewtopic.php?p=$id&view=api"
}

sub serialize {
  my ($self, $body, $req) = @_;

  my $root = HTML::TreeBuilder->new;
  $root->store_comments(1);
  $root->parse($body);
  $root->eof;

  my $id = $req->captures->[0];
  my $comment = $root->look_down("data-post-id" => $req->captures->[0]);

  die "could not find comment" unless $comment;

  my $link = $comment->look_down(href => "#comment-$id");
  $link->attr("href", $req->url);
  $link->attr("_target", "blank");
  $comment->attr($_, undef) for qw/id class data-post-id/;
  $comment->attr(class => "ars-comment-embed");

  my $title = $root->look_down(_tag => "~comment")->attr("text");
  $title =~ s/^\s+//;
  $title =~ s/\s+$//;

  return +{
    title => $title,
    html => $comment->as_HTML,
  }; 
}

1;

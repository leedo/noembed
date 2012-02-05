package Noembed::Source::Github;

use AnyEvent;
use JSON;

use parent "Noembed::Source";

sub shorturls { 'http://git.io/[_0-9a-zA-Z]+' }
sub patterns { 'https?://github.com/([^/]+)/([^/]+)/commit/(.+)' }
sub provider_name { "Github Commit" }

sub build_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = @{$req->captures};
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  my $commit = from_json $body;
  my $cv = AE::cv;

  # syntax highlight the patches
  for my $file (@{$commit->{files}}) {
    $cv->begin;

    Noembed::Util::colorize $file->{patch},
      lexer => "diff",
      sub {
        $file->{patch} = html($_[0]);
        $cv->end;
      };
  }

  $cv->cb(sub {$cb->($commit)});
}

sub serialize {
my ($self, $commit) = @_;

  my $message = (split "\n", $commit->{commit}{message})[0];
  return +{
    html => $self->render($commit),
    title => "$message by $commit->{commit}{author}{name}",
  };
}

1;

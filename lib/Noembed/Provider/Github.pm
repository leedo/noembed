package Noembed::Provider::Github;

use JSON;

use parent "Noembed::Provider";

sub shorturls { 'http://git\.io/[_0-9a-zA-Z]+' }
sub patterns { 'https?://github\.com/([^/]+)/([^/]+)/commit/(.+)' }
sub provider_name { "Github Commit" }

sub build_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = @{$req->captures};
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

sub serialize {
  my ($self, $body, $req) = @_;

  my $commit = from_json $body;

  die "no files" unless @{$commit->{files}};

  for my $file (@{$commit->{files}}) {
    my $colorized = Noembed::Util->colorize($file->{patch});
    $file->{patch} = Noembed::Util->html($colorized);
  }

  my $message = (split "\n", $commit->{commit}{message})[0];

  return +{
    html => $self->render($commit),
    title => "$message by $commit->{commit}{author}{name}",
  };
}

1;

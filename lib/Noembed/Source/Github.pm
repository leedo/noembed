package Noembed::Source::Github;

use Text::MicroTemplate qw/encoded_string/;
use Noembed::Pygmentize;
use AnyEvent;
use JSON;

use parent "Noembed::Source";

sub prepare_source {
  my $self = shift;
  $self->{pyg} = Noembed::Pygmentize->new(lexer => "diff");
}

sub shorturls { 'http://git.io/[_0-9a-zA-Z]+' }
sub patterns { 'https?://github.com/([^/]+)/([^/]+)/commit/(.+)' }
sub provider_name { "Github Commit" }

sub request_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = @{$req->captures};
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

sub post_download {
  my ($self, $body, $cb) = @_;
  my $commit = decode_json $body;
  my $cv = AE::cv;

  # syntax highlight the patches
  for my $file (@{$commit->{files}}) {
    $cv->begin;
    $self->{pyg}->colorize($file->{patch}, sub {
      $file->{patch} = encoded_string $_[0];
      $cv->end;
    });
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

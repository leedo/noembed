package Noembed::Source::Github;

use Text::MicroTemplate qw/encoded_string/;
use Noembed::Pygmentize;
use File::Which qw/which/;
use JSON;

use parent "Noembed::Source";

sub prepare_source {
  my $self = shift;

  my $pygmentize = which "pygmentize";
  die "couldn't find pygmentize program" unless $pygmentize;

  $self->{pyg} = Noembed::Pygmentize->new(
    bin => $pygmentize,
    lexer => "diff",
  );
}

sub shorturls { 'http://git.io/[0-9a-zA-Z]' }
sub patterns { 'https?://github.com/([^/]+)/([^/]+)/commit/(.+)' }
sub provider_name { "Github Commit" }

sub request_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = $req->captures;
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json $body;

  my $message = (split "\n", $data->{commit}{message})[0];

  # syntax highlight the patches
  for my $file (@{$data->{files}}) {
    $file->{patch} = encoded_string $self->{pyg}->colorize($file->{patch});
  }

  return +{
    html => $self->render($data),
    title => "$message by $data->{commit}{author}{name}",
  };
}

1;

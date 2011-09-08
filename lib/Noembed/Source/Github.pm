package Noembed::Source::Github;

use Text::MicroTemplate qw/encoded_string/;
use Text::VimColor;
use JSON;

use parent "Noembed::Source";

sub prepare_source {
  my $self = shift;
  $self->{re} = qr{https?://github.com/([^/]+)/([^/]+)/commit/(.+)}i;
  $self->{vim} = Text::VimColor->new(filetype => "diff");
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

sub request_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = $req->url =~ $self->{re};
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

sub provider_name { "Github Commit" }

sub filter {
  my ($self, $body) = @_;
  my $data = decode_json $body;

  # syntax highlight the patches
  for my $file (@{$data->{files}}) {
    $file->{patch} = encoded_string $self->{vim}->syntax_mark_string(\($file->{patch}))->html;
  }

  return +{
    html => $self->render($data),
    title => "$data->{commit}{message} by $data->{commit}{author}{name}",
  };
}

1;

package Noembed::Source::Github;

use Text::MicroTemplate qw/encoded_string/;
use Text::VimColor;
use JSON;

use parent "Noembed::Source";

sub prepare_source {
  my $self = shift;
  $self->{vim} = Text::VimColor->new(filetype => "diff");
}

sub pattern { 'https?://github.com/([^/]+)/([^/]+)/commit/(.+)' }
sub provider_name { "Github Commit" }

sub request_url {
  my ($self, $req) = @_;
  my ($user, $repo, $hash) = $req->url_captures;
  return "https://api.github.com/repos/$user/$repo/commits/$hash";
}

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

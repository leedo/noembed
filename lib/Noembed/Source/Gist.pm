package Noembed::Source::Gist;

use Text::MicroTemplate qw/encoded_string/;
use Noembed::Pygmentize;
use JSON;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{pyg} = Noembed::Pygmentize->new;
}

sub provider_name { "Gist" }
sub patterns { 'https?://gist\.github\.com/([0-9a-fA-f]+)' }

sub request_url {
  my ($self, $req) = @_;
  return "https://api.github.com/gists/".$req->captures->[0];
}

sub filter {
  my ($self, $body) = @_;
  my $gist = decode_json $body;

  for my $file (values %{$gist->{files}}) {
    $file->{content} = encoded_string $self->{pyg}->colorize(
      $file->{content}, lexer => lc $file->{language}
    );
  }

  return +{
    title => $gist->{description},
    html => $self->render($gist),
  };
}

1;

package Noembed::Provider::Gist;

use JSON;

use parent 'Noembed::Provider';

sub provider_name { "Gist" }
sub patterns { 'https?://gist\.github\.com/(?:[-0-9a-zA-Z]+/)?([0-9a-fA-f]+)' }

sub build_url {
  my ($self, $req) = @_;
  return "https://api.github.com/gists/".$req->captures->[0];
}

sub serialize {
  my ($self, $body, $req) = @_;

  my $gist = from_json $body;

  die "no files" unless %{$gist->{files}};

  for my $file (values %{$gist->{files}}) {
    $file->{content} = Noembed::Util->colorize($file->{content},
      language => lc $file->{language},
      filename => lc $file->{filename},
    );
  }

  return +{
    title => ($gist->{description} || $gist->{html_url}) . ($gist->{user} ? " by $gist->{user}{login}" : ""),
    html => $self->render($gist),
  };
}

1;

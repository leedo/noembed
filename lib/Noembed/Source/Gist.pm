package Noembed::Source::Gist;

use AnyEvent;
use JSON;

use parent 'Noembed::Source';

sub provider_name { "Gist" }
sub patterns { 'https?://gist\.github\.com/([0-9a-fA-f]+)' }

sub build_url {
  my ($self, $req) = @_;
  return "https://api.github.com/gists/".$req->captures->[0];
}

sub post_download {
  my ($self, $body, $req, $cb) = @_;
  my $gist = from_json $body;
  my $cv = AE::cv;

  die "no files" unless %{$gist->{files}};

  for my $file (values %{$gist->{files}}) {
    $cv->begin;

    Noembed::Util::colorize $file->{content},
      language => lc $file->{language},
      filename => lc $file->{filename},
      sub {
        $file->{content} = html($_[0]);
        $cv->end;
      };
  }

  $cv->cb(sub {$cb->($gist)});
}

sub serialize {
  my ($self, $gist) = @_;

  return +{
    title => ($gist->{description} || $gist->{html_url}) . ($gist->{user} ? " by $gist->{user}{login}" : ""),
    html => $self->render($gist),
  };
}

1;

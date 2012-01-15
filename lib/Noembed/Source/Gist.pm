package Noembed::Source::Gist;

use Noembed::Pygmentize;
use AnyEvent;
use JSON;

use parent 'Noembed::Source';

sub prepare_source {
  my $self = shift;
  $self->{pyg} = Noembed::Pygmentize->new;
}

sub provider_name { "Gist" }
sub patterns { 'https?://gist\.github\.com/([0-9a-fA-f]+)' }

sub build_url {
  my ($self, $req) = @_;
  return "https://api.github.com/gists/".$req->captures->[0];
}

sub post_download {
  my ($self, $body, $cb) = @_;
  my $gist = from_json $body;
  my $cv = AE::cv;

  for my $file (values %{$gist->{files}}) {
    $cv->begin;
    $self->{pyg}->colorize($file->{content},
      language => lc $file->{language},
      filename => lc $file->{filename},
      sub {
        my $colorized = shift;
        $file->{content} = html($colorized);
        $cv->end;
      }
    );
  }

  $cv->cb(sub {$cb->($gist)});
}

sub serialize {
  my ($self, $gist) = @_;

  return +{
    title => ($gist->{description} || $gist->{html_url}) . " by $gist->{user}{login}",
    html => $self->render($gist),
  };
}

1;

package Noembed::Provider::Twitlonger;

use parent 'Noembed::Provider';

use XML::Simple ();

sub provider_name { 'Twitlonger' }
sub shorturls { 'http://tl\.gd/[^/]+' }
sub patterns { 'http://www\.twitlonger\.com/show/[a-zA-Z0-9]+' }

sub build_url {
  my ($self, $req) = @_;
  return $req->url . "/fulltext";
}

sub serialize {
  my ($self, $body) = @_;
  my $data = XML::Simple::XMLin($body);

  die $data->{error} if exists $data->{error};
  die "no post" unless exists $data->{post};

  return {
    title => "TwitLonger messages by $data->{post}{user}",
    html  => $self->render($data->{post}),
    post  => $data->{post},
  };
}

1;

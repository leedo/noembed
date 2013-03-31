package Noembed::Provider::PostError;

use parent 'Noembed::Provider';

sub provider_name { "Post hook error" }
sub patterns { 'http://noembed.org/posterror' }

sub post_download {
  my ($body, $req, $cb) = @_;
  $req->http_get("http://nonexistent", sub {
    die $_[1]->{Reason};
  });  
}

sub serialize {
  return +{
    title => "Should not get here",
    html  => "Should not get here",
  };
}

1;

package Noembed::Source::PreError;

use parent 'Noembed::Source';

sub provider_name { "Pre hook error" }
sub patterns { 'http://noembed.org/preerror' }

sub pre_download {
  my ($self, $req, $cb) = @_;
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

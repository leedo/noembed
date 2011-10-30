use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Plack::Util;
use Noembed;

my $noembed = Noembed->new;
my $ref_blacklist = [qr{antronio},];

my $refcheck = sub {
  my $app = shift;
  sub {
    my $env = shift;
    for (@$ref_blacklist) {
      return [401, [], ['forbidden']] if $env->{HTTP_REFERER} =~ $_;
    }
    return $app->($env);
  };
};

sub cache {
  my $seconds = shift;
  $seconds = 31536000 unless defined $seconds;

  return sub {
    my $app = shift;
    sub {
      my $env = shift;
      my $res = $app->($env);
      Plack::Util::response_cb($res, sub {
        my $res = shift;
        Plack::Util::header_set($res->[1], "Cache-Control", "max-age=$seconds");
        return
      });
    };
  };
}

builder {
  enable ReverseProxy;
  enable $refcheck;

  mount "/"      => Plack::App::File->new(file => "index.html");
  mount "/demo"  => Plack::App::File->new(file => "demo.html");
  mount "/noembed.css" => builder {
    enable cache(3600);
    sub { $noembed->css_response };
  };

  mount "/providers" => builder {
    enable cache(3600);
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    enable JSONP;
    sub { $noembed->providers_response };
  };

  mount "/embed" => builder {
    enable cache(31556925);
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    enable JSONP;
    $noembed->to_app;
  };
};

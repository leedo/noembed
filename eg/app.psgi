use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Noembed;

my $noembed = Noembed->new;
my $ref_blacklist = [
  qr{antronio},
];

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

builder {
  mount "/"      => Plack::App::File->new(file => "index.html");
  mount "/demo"  => Plack::App::File->new(file => "demo.html");
  mount "/noembed.css" => sub { $noembed->css_response };
  mount "/providers" => builder {
    enable ReverseProxy;
    enable $refcheck;
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    sub { $noembed->providers_response };
  };
  mount "/embed" => builder {
    enable ReverseProxy;
    enable $refcheck;
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    enable JSONP;
    $noembed->to_app;
  }
};

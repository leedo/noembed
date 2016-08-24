use Plack::App::File;
use Plack::Builder;
use Plack::Util;

use Noembed::Request;
use Noembed::App;
use Noembed::Config;

my $config = Noembed::Config->new("config.json");
my $noembed = Noembed::App->new($config);

builder {
  enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
          "Plack::Middleware::ReverseProxy";

  mount "/"      => Plack::App::File->new(file => $config->{share_dir} . "/demo/index.html")->to_app;
  mount "/demo"  => Plack::App::File->new(file => $config->{share_dir} . "/demo/demo.html")->to_app;
  mount "/favicon.ico" => sub { [404, ["Content-Type", "text/plain"], ["not found"]] };

  mount "/providers" => builder {
    enable JSONP;
    sub { $noembed->providers_response };
  };

  mount "/embed" => builder {
    enable JSONP;
    sub {
      my $env = shift;
      my $req = Noembed::Request->new($env);
      $noembed->handle_request($req);;
    }
  };
};

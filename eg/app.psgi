use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Plack::Util;
use Noembed;

my $noembed = Noembed->new;

builder {
  enable ReverseProxy;

  mount "/"      => Plack::App::File->new(file => "index.html");
  mount "/demo"  => Plack::App::File->new(file => "demo.html");
  mount "/noembed.css" => sub { $noembed->css_response };
  mount "/favicon/" => Plack::App::File->new(root => Noembed::share_dir . "/icons/");

  mount "/providers" => builder {
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    enable JSONP;
    sub { $noembed->providers_response };
  };

  mount "/embed" => builder {
    enable 'CrossOrigin', origins => '*', methods => '*', headers => '*';
    enable JSONP;
    $noembed->to_app;
  };
};

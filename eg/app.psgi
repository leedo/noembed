use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Plack::Util;
use Noembed;

my $noembed = Noembed->new;

builder {
  enable ReverseProxy;

  mount "/"      => Plack::App::File->new(file => "index.html")->to_app;
  mount "/demo"  => Plack::App::File->new(file => "demo.html")->to_app;
  mount "/noembed.css" => sub { $noembed->css_response };
  mount "/favicon/" => Plack::App::File->new(root => Noembed::share_dir . "/icons/")->to_app;
  mount "/docs"  => Plack::App::File->new(root => "docs/")->to_app;

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

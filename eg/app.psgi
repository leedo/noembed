use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Noembed;

builder {
  mount "/"      => Plack::App::File->new(file => "index.html");
  mount "/demo"  => Plack::App::File->new(file => "demo.html");
  mount "/embed" => builder {
    enable JSONP;
    Noembed->new->to_app;
  }
};

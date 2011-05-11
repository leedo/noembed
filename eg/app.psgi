use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Noembed;

builder {
  enable JSONP;
  mount "/demo.html" => Plack::App::File->new(file => "demo.html");
  mount "/embed" => Noembed->new->to_app;
};

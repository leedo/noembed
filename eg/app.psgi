use lib '../lib';

use Plack::App::File;
use Plack::Builder;
use Noembed;

my $noembed = Noembed->new;

builder {
  mount "/"      => Plack::App::File->new(file => "index.html");
  mount "/demo"  => Plack::App::File->new(file => "demo.html");
  mount "/demo/providers" => sub { $noembed->providers_response };
  mount "/embed" => builder {
    enable JSONP;
    $noembed->to_app;
  }
};

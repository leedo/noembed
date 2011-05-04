use lib 'lib';

use Plack::Builder;
use Noembed;

builder {
  enable JSONP;
  mount "/embed" => Noembed->new->to_app;
};

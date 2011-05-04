use lib 'lib';

use Plack::Builder;
use Noembed;

builder {
  enable JSONP;
  mount "/" => Noembed->new->to_app;
};

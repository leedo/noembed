package Noembed::JSONP;
use strict;
use parent qw(Plack::Middleware);
use Plack::Util;
use URI::Escape ();

use Plack::Util::Accessor qw/callback_key/;

sub prepare_app {
    my $self = shift;
    unless (defined $self->callback_key) {
        $self->callback_key('callback');
    }
}

sub call {
    my($self, $env) = @_;
    my $res = $self->app->($env);
    $self->response_cb($res, sub {
        my $res = shift;
        if (defined $res->[2]) {
            my $h = Plack::Util::headers($res->[1]);
            my $callback_key = $self->callback_key;
            if ($h->get('Content-Type') =~ m!/(?:json|javascript)! &&
                $env->{QUERY_STRING} =~ /(?:^|&)$callback_key=([^&]+)/) {
                my $cb = URI::Escape::uri_unescape($1);
                {
                    my $body;
                    Plack::Util::foreach($res->[2], sub { $body .= $_[0] });
                    my $jsonp = "$cb($body)";
                    $res->[2] = [ $jsonp ];
                    $h->set('Content-Length', length $jsonp);
                    $h->set('Content-Type', 'text/javascript');
                }
            }
        }
    });
}

1;

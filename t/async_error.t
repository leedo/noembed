use Noembed::Test;
use Test::More;

test_embed
  url => "http://noembed.org/preerror",
  callback => sub {
    my ($data, $cv) = @_;
    ok $data->{error} =~ /Device not configured/, "http get error";
    is $data->{url}, "http://noembed.org/preerror", "url key set";
    $cv->send;
  };

test_embed
  url => "http://noembed.org/posterror",
  callback => sub {
    my ($data, $cv) = @_;
    ok $data->{error} =~ /Device not configured/, "http get error";
    is $data->{url}, "http://noembed.org/posterror", "url key set";
    $cv->send;
  };

done_testing();

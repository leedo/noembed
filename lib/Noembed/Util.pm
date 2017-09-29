package Noembed::Util;

use Encode;
use JSON::XS ();
use LWP::UserAgent;
use Text::MicroTemplate ();
use HTML::TreeBuilder;
use Imager;

my $ua;

sub get_ua {
  $ua ||= LWP::UserAgent->new(
    timeout    => 5,
    keep_alive => 32,
    agent      => "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36",
  );
  $ua->ssl_opts(timeout => 5, Timeout => 5);
  $ua;
}

sub http_get {
  my ($class, $url) = @_;

  my $ua = get_ua();
  $ua->requests_redirectable(["GET"]);
  my $res = $ua->get($url);

  return $res;
}

sub http_resolve {
  my ($class, $url) = @_;

  my $uri = URI->new($url);

  my $ua = get_ua();
  $ua->requests_redirectable(undef);
  my $res = $ua->head($url);

  if ($res->header("location")) {
    $url = $res->header("location");
    if ($url !~ m{^https?://}) {
      $uri->path_query($url);
      $url = $uri->as_string;
    }
  }

  return $url;
}

sub dimensions {
  my ($class, $url, $req) = @_;

  my $maxw = $req->parameters->{maxwidth};
  my $maxh = $req->parameters->{maxheight};

  my $res = Noembed::Util->http_get($url);

  if ($res->code == 200) {
    my $image = Imager->new(data => $res->content);
    my ($w, $h) = ($image->getwidth, $image->getheight);

    if ($maxh and $h > $maxh) {
      $w = $w * ($maxh / $h);
      $h = $maxh;
    }
    if ($maxw and $w > $maxw) {
      $h = $h * ($maxw / $w);
      $w = $maxw;
    }
    return(int($w), int($h));
  }
}

sub html {
  my $class = shift;
  Text::MicroTemplate::encoded_string(shift);
}

sub clean_html {
  my $class = shift;
  my $html = shift;
  my $tree = HTML::TreeBuilder->new_from_content(\$html);
  return "" unless $tree;

  $tree->ignore_ignorable_whitespace(0);
  $tree = $tree->disembowel;
  $_->delete for $tree->find("script");

  $tree->look_down(sub {
    my $elem = shift;
    my %attr = $elem->all_external_attr;
    $elem->attr($_, undef) for grep {/^on/i or $attr{$_} =~ /^javascript:/i} sort keys %attr;
    return ();
  });

  $html = $tree->as_HTML;
  $tree->delete;

  Noembed::Util->html($html);
}

1;

package Noembed::Util;

use Encode;
use JSON::XS ();
use LWP::UserAgent;
use Text::MicroTemplate ();
use HTML::TreeBuilder;
use Noembed::Pygmentize;

my $pygmentize = Noembed::Pygmentize->new;
my $ua = LWP::UserAgent->new(
  agent => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en) AppleWebKit/419.3 (KHTML, like Gecko) Safari/419.3"
);

sub http_get {
  my ($class, $url, @options) = @_;

  my $res = $ua->get($url);

  return $res;
}

sub http_resolve {
  my ($class, $url, $cb) = @_;

  my $res = Noembed::Util->http_get($url);

  if ($res->header("location")) {
    $url = $res->header->("location");
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

sub colorize {
  my ($class, $text, %options) = @_;
  return Noembed::Util->html($pygmentize->colorize($text, %options));
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
    $elem->attr($_, undef) for grep {/^on/i or $attr{$_} =~ /^javascript:/i} keys %attr;
    return ();
  });

  $html = $tree->as_HTML;
  $tree->delete;

  Noembed::Util->html($html);
}

1;

package Noembed::Source::YouTube;

use Web::Scraper;

use parent 'Noembed::Source';

my $re = qr{http://[^\.]+\.youtube\.com/watch\?v=(.+)}i;

sub prepare_source {
  my $self = shift;
  $self->{scraper} = scraper {
    process "title", title => 'TEXT';
    process "body", html => sub {
      $_[0]->tag('div');
      $_[0]->attr('class', 'youtube');
      $_[0]->as_HTML("");
    };
  };
}

sub request_url {
  my ($self, $url) = @_;
  my ($id) = $url =~ $re;
  return "http://www.youtube.com/embed/$id";
}

sub matches {
  my ($self, $url) = @_;
  return $url =~ $re;
}

sub filter {
  my ($self, $body) = @_;
  my $res = $self->{scraper}->scrape($body);
  return $res;
}

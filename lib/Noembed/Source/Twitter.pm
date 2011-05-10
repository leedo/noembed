package Noembed::Source::Twitter;

use JSON;
use Text::MicroTemplate qw(:all);

use parent 'Noembed::Source';

sub matches {
  my ($self, $url) = @_;
  return $url =~ $self->{re};
}

sub prepare_source {
  my $self = shift;
  $self->{template} = get_template();
  $self->{re} = qr{https?://(?:www\.)?twitter\.com/(?:#!/)?[^/]+/status(?:es)?/(\d+)};
}

sub request_url {
  my ($self, $url, $params) = @_;
  if ($url =~ $self->{re}) {
    my $id = $1;
    return "http://api.twitter.com/1/statuses/show/$id.json";
  }
}

sub provider_name { "Twitter" }

sub filter {
  my ($self, $body) = @_;

  my $data = decode_json $body;
  $data->{source} = encoded_string $data->{source};
  my $html = $self->{template}->($data)->as_string; 
  +{
    title => "Tweet from $data->{user}{screen_name}",
    html => $html,
  };
}

sub get_template {

  my $template_string = q{
? my $data = $_[0];
? my $user = $data->{user};
<div class="tweet">
  <div class="tweet_user">
    <img class="tweet_image" src="<?= $user->{profile_image_url} ?>">
    <div class="tweet_screen_name"><?= $user->{screen_name} ?></div>
    <div class="tweet_name"><?= $user->{name} ?></div>
  </div>
  <div class="tweet_text"><?= $data->{text} ?></div>
  <div class="tweet_info">
    <span class="tweet_created_at"><?= $data->{created_at} ?></span>
    via <?= $data->{source} ?>
  </div>
<div>
  };

  return build_mt($template_string);
}

1;

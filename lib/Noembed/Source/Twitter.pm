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
? my $id = $data->{id};
? my $user = $data->{user};
<style type="text/css">
  #tweet-<?= $id ?> {
    background-color: #fafafa;
    color: #333;
    max-width: 400px;
    border-radius: 5px;
    -webkit-box-shadow: 0px 2px 2px rgba(0,0,0,0.5);
    padding: 10px 15px;
  }
  #tweet-<?= $id ?> a {
    color: #<?= $user->{profile_link_color} ?>;
    text-decoration: none;
  }
  #tweet-<?= $id ?> a:hover {
    text-decoration: underline;
  }
  #tweet-<?= $id ?> div.tweet_image {
    float: left;
    margin-right: 5px;
  }
  #tweet-<?= $id ?> div.tweet_text {
    clear: both;
    padding: 8px 0;
  }
  #tweet-<?= $id ?> div.tweet_screen_name {
    font-weight: bold;
    font-size: 16px;
    margin: 2px 0;
  }
  #tweet-<?= $id ?> div.tweet_info,
  #tweet-<?= $id ?> div.tweet_name {
    font-size: 12px;
    color: #999;
  }
</style>
<div class="tweet" id="tweet-<?= $id ?>">
  <div class="tweet_user">
    <div class="tweet_image">
      <a href="http://www.twitter.com/<?= $user->{screen_name} ?>">
        <img src="<?= $user->{profile_image_url} ?>">
      </a>
    </div>
    <div class="tweet_screen_name">
      <a href="http://www.twitter.com/<?= $user->{screen_name} ?>">
        @<?= $user->{screen_name} ?>
      </a>
    </div>
    <div class="tweet_name"><?= $user->{name} ?></div>
  </div>
  <div class="tweet_text"><?= $data->{text} ?></div>
  <div class="tweet_info">
    <a href="http://www.twitter.com/<?= $user->{screen_name}?>/status/<?= $id ?>"><span class="tweet_created_at"><?= $data->{created_at} ?></span></a>
    via <?= $data->{source} ?>
  </div>
<div>
<script type="text/javascript">
  var months = ['Jan','Feb','Mar','Apr','June','July','Aug','Sept','Oct','Nov','Dec'];
  var elem = document.getElementById("tweet-<?= $id ?>").down(".tweet_created_at");
  var date = new Date(elem.innerHTML);

  var hours = date.getHours() + 1;
  if (hours.length < 2) hours = "0"+hours;
  var minutes = date.getMinutes();
  if (minutes.length < 2) minutes = "0"+minutes;

  elem.innerHTML =  hours + ":" + minutes+ " " + months[date.getMonth()]
                 + " " + date.getDate() + ", " + date.getFullYear();
</script>
  };

  return build_mt($template_string);
}

1;

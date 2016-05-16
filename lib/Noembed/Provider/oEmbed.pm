package Noembed::Provider::oEmbed;

use parent 'Noembed::oEmbedProvider';

use LWP::UserAgent;
use JSON;

our @PROVIDERS;

sub provider_name { "oEmbed" }

sub patterns {
  map { $_->[1] } @PROVIDERS;
}

sub oembed_url {
  my ($self, $req) = @_;
  for my $scheme (@PROVIDERS) {
    if ($req->url =~ $scheme->[0]) {
      return $scheme->[2];
    }
  }
}

sub prepare_provider {
  my $self = shift;
  my $ua = LWP::UserAgent->new;
  my $res = $ua->get("http://oembed.com/providers.jsons");
  my $providers;

  if ($res->code == 200) {
    $providers = decode_json $res->content;
  }
  else {
    warn "unable to fetch providers.json, loading static";
    $providers = do {
      local $/;
      open my $fh, "<", $self->{share_dir} . "/providers.json" or die $!;
      decode_json <$fh>;
    };
  }

  my @lookup;

  for my $provider (@$providers) {
    for my $endpoint (@{ $provider->{endpoints} }) {
      $endpoint->{url} =~ s/\{format\}/json/;
      for my $scheme (@{ $endpoint->{schemes} }) {
        $scheme =~ s/\*/[^\/]+/g;
        push @PROVIDERS, [qr{$scheme}, $scheme, $endpoint->{url}];
      }
    }
  }
}

1;

package Noembed::Provider::oEmbed;

use parent 'Noembed::oEmbedProvider';

use LWP::UserAgent;
use JSON;

sub provider_name { "oEmbed" }

sub patterns {
  my $self = shift;
  map { $_->[1] } $self->providers;
}

sub providers {
    my $self = shift;
    return @{ $self->{providers} };
}

sub oembed_url {
  my ($self, $req) = @_;
  for my $scheme ($self->providers) {
    if ($req->url =~ $scheme->[0]) {
      return $scheme->[2];
    }
  }
}

sub prepare_provider {
  my $self = shift;
  $self->{providers} = [];

  my $ua = LWP::UserAgent->new;
  my $res = $ua->get("http://oembed.com/providers.json");
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
        $scheme =~ s/([.?])/\\$1/g;
        $scheme =~ s/^https?:/https?:/;
        $scheme =~ s/\*/.*/g;
        push @{ $self->{providers} }, [qr{$scheme}, $scheme, $endpoint->{url}];
      }
    }
  }
}

1;

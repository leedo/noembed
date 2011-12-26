package Noembed::Source::Amazon;

use parent 'Noembed::Source';

use URI::Amazon::APA;
use XML::Simple;
use JSON;

sub prepare_source {
  my $self = shift;
  $self->{secret} = do {
    open my $fh, '<', "$ENV{HOME}/.aws_secret";
    local $/;
    my $json = <$fh>;
    decode_json $json;
  };
}

sub provider_name { "Amazon" }
sub patterns { 'http://www\.amazon\.com/(?:.+/)?[gd]p/(?:product/)?([^/]+)', 'http://amzn\.com/([^/]+)' }

sub request_url {
  my ($self, $req) = @_;
  my $asin = $req->captures->[0];
  my $u = URI::Amazon::APA->new('http://webservices.amazon.com/onca/xml');
  $u->query_form(
    Service => 'AWSECommerceService',
    AssociateTag => 'usealiceorg-20',
    Operation => 'ItemLookup',
    ResponseGroup => 'Medium',
    ItemId => $asin,
  );
  $u->sign(%{$self->{secret}});
  return $u->as_string;
}

sub serialize {
  my ($self, $body) = @_;
  my $data = XMLin($body,
    ForceArray => [qw/EditorialReview ImageSet Item/],
  );
  my $item = $data->{Items}{Item}[0];
  my $info = {
    title  => $item->{ItemAttributes}{Title},
    price  => $item->{ItemAttributes}{ListPrice}{FormattedPrice},
    group  => $item->{ItemAttributes}{ProductGroup},
    review => html($item->{EditorialReviews}{EditorialReview}[0]{Content}),
    image  => $item->{ImageSets}{ImageSet}[0]{TinyImage},
    url    => $item->{DetailPageURL},
  };
  return +{
    html  => $self->render($info),
    title => $info->{title} || $info->{url},
    url   => $info->{url},
  };
}

1;

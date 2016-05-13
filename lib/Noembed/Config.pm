package Noembed::Config;

use JSON::XS;

sub new {
	my ($class, $file) = @_;

  my $data = do {
    local $/;
    open my $fh, '<', $file;
    decode_json <$fh>;
  };

  bless {
    image_prefix => $data->{image_prefix},
    share_dir    => $data->{share_dir},
  }, $class;
}

1;

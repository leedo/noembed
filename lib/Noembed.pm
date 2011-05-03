package Noembed;

use Class::Load qw/try_load_class/;

use parent 'Plack::Component';

our $DEFAULT = [ qw/oEmbed Wikipedia/ ];

sub prepare_app {
  my $self = shift;

  $self->{sources} ||= $DEFAULT;
  $self->{providers} = [];

  $self->register_provider($_) for @{$self->{sources}};
  delete $self->{sources};
}

sub register_provider {
  my ($self, $class) = @_;

  if ($class !~ s/^\+//) {
    $class = "Noembed::Source::$class";
  }

  my ($loaded, $error) = try_load_class($class);
  if ($loaded) {
    my $provider = $class->new;
    push @{ $self->{providers} }, $provider;
  }
  else {
    warn "Could not load provider $class: $error";
  }
}

1;

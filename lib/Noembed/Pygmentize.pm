package Noembed::Pygmentize;

use AnyEvent::Worker;
use File::Which qw/which/;

sub new {
  my ($class, %args) = @_;

  bless {
    bin     => $args{bin}     || which("pygmentize") || "/usr/bin/pygmentize",
    lexer   => $args{lexer},
    format  => $args{format}  || "html",
    options => $args{options} || "linenos=True,encoding='utf-8'",
  }, $class;
}

sub colorize {
  my $cb = pop;
  my ($self, $text, %opts) = @_;

  $opts{lexer}   = $self->{lexer}   unless defined $opts{lexer};
  $opts{format}  = $self->{format}  unless defined $opts{format};
  $opts{options} = $self->{options} unless defined $opts{options};

  $self->worker->do(colorize => $text, %opts, sub {
    if ($@) {
      warn $@;
      return $cb->("<pre>$text</pre>");
    }
    $cb->($_[1]);
  });
}

sub worker {
  my $self = shift;
  $self->{worker} ||= AnyEvent::Worker->new(
    ['Noembed::Pygmentize::Worker' => $self->{bin}]);
}


package Noembed::Pygmentize::Worker;

use IPC::Run;
use List::MoreUtils qw/any/;
use Encode;

sub new {
  my ($class, $bin) = @_;
  bless { bin => $bin }, $class;
}

sub find_lexer {
  my ($self, $name, $filename) = @_;
  my ($extension) = $filename =~ /\.(.+)$/;

  for my $lexer (@{$self->lexers}) {
    if (any {$name eq $_} @{$lexer->{names}}) {
      return $lexer->{names}[0];
    }
    if (any {$extension eq $_} @{$lexer->{extensions}}) {
      return $lexer->{names}[0];
    }
  }

  return "text";
}

sub lexers {
  my $self = shift;
  $self->{lexers} ||= $self->build_lexers;
}

sub build_lexers {
  my $self = shift;

  my($in, $out, $err);
  my $pid = IPC::Run::run([$self->{bin}, "-L", "lexers"], \$in, \$out, \$err, );

  my @lexers;
  my (@names, @extensions);

  for my $line (split "\n", $out) {

    # new language
    if ($line =~ /^* (.+):/) {

      # add previous language if there is one
      if (@names) {
        push @lexers, {
          names => [@names],
          extensions => [@extensions],
        };
      }

      @names = split ", ", $1;
      @extensions = ();
    }

    elsif ($line =~ /filenames (.+)/) {
      @extensions = map {substr $_, 2} split ", ", $1;
    }
  }

  return \@lexers;
}

sub colorize {
  my ($self, $text, %opts) = @_;

  $text = encode("utf-8", "$text\n");
  my($out, $err);

  eval {
    IPC::Run::run([$self->command(%opts)], \$text, \$out, \$err, IPC::Run::timeout(3));
  };

  if ($err or $@) {
    die "$err: $@";
  }

  return decode("utf-8", $out);
}

sub command {
  my ($self, %opts) = @_;

  $opts{lexer} = $self->find_lexer($opts{language}, $opts{filename})
    unless defined $opts{lexer};

  return (
    $self->{bin},
    '-l', $opts{lexer},
    '-f', $opts{format},
    '-O', $opts{options},
  );
}

1;

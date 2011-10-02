package Noembed::Pygmentize;

use Carp;
use IPC::Open3;
use Symbol 'gensym'; 

sub new {
  my ($class, %args) = @_;

  bless {
    bin    => $args{bin}    ||"/usr/bin/pygmentize",
    lexer  => $args{lexer}  || "text",
    format => $args{format} || "html",
    options => $args{options} || "linenos=True,noclasses=True",
  }, $class;
}

sub colorize {
  my ($self, $text) = @_;

  my($wtr, $rdr, $err);
  $err = gensym; #ugh

  my $pid = open3($wtr, $rdr, $err, $self->command);
  print $wtr $text;
  close $wtr;
  waitpid($pid, 0);

  local $/;
  my $err = <$err>;
  my $out = <$rdr>;

  carp $err if $err;
  $out =~ s{</pre></div>\Z}{</pre>\n</div>};
  return $out;
}

sub command {
  my $self = shift;
  return (
    $self->{bin},
    '-l', $self->{lexer},
    '-f', $self->{format},
    '-O', $self->{options},
  );
}

1;

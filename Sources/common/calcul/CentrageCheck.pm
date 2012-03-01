package calcul::CentrageCheck;

use strict;
use Gtk2;

sub new {
  my ($class, $limite_centrage_coords) = @_;
  my $this = bless({}, $class);
  $this->set_limite_centrage_coords($limite_centrage_coords) if ($limite_centrage_coords);
  
  return $this;
}

sub set_limite_centrage_coords {
  my ($this, $coord) = @_;
  
  # $this->{_LIMITE_CENTRAGE_COORDS} = $coord;
  my @ordered = map { @$_ } @$coord;
 # print join(' ', @ordered)."\n";
  $this->{_REGION} = Gtk2::Gdk::Region->polygon (\@ordered, 'winding-rule');
  #print "ouais\n" if ($this->{_REGION}->point_in(4400, 2000));
}

sub is_good {
  my ($this, $bras, $masse) = @_;
  #p#rint "is_good $bras $masse \n";
  #print scalar($this->{_REGION}->get_rectangles). ' ';
  my $is_good = $this->{_REGION}->point_in($bras, $masse);
  if ($is_good) {
   # print "ouais gros\n";
  }
  else {
 #    print "merde\n";
  }
  return $is_good;
}

1;



package CairoBuffer;

use Cairo;

sub new {
	my ($class, $w ,$h) = @_;
	my $this = bless({}, $class);
	$this->create_new_cr($w, $h);
	return $this;
}

sub cr {
	return shift->{_CR};
}

#création d'une nouvelle surface en cache de la taille $w, $h souhaitée
#création d'un nouveau contexte cairo
sub create_new_cr {
  my ($this, $w, $h) = @_;
  my $surface = Cairo::ImageSurface->create('argb32', $w, $h);
  $this->{_CR} = Cairo::Context->create ($surface);
}

sub clear {
	my $cr = shift->cr;
  $cr->save();
  $cr->set_operator('clear');
  $cr->paint();
  $cr->restore();
}

sub draw_to {
	my ($this, $to_cr) = @_;
	$to_cr->set_source_surface($this->cr->get_target, 0., 0.);
  $to_cr->paint;
}

1;

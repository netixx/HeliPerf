package models::Pilote;

=pod
****CLASSE Pilote***
Représente un pilote ayant une masse et un bras, un trigramme, une fonction

=cut

use strict;
use base qw(models::BaseItem);

sub new {
	my ($class, $masse, $bras, $trigramme, $fction) = @_;
	my $this = models::BaseItem->new($bras, $masse);
	$this->{_TRIGRAMME} = $trigramme;
	$this->{_FONCTION} = $fction;
	return bless ($this, $class);
}


sub get_trigramme {
	return shift->{_TRIGRAMME};
}

sub get_fonction {
	return shift->{_FONCTION};
}


1;

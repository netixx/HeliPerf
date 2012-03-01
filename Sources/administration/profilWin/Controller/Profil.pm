package administration::profilWin::Controller::Profil; 

use strict;

sub new {
	my ($class, $profil) = @_;
	return bless ({_MODEL => $profil}, $class);
	
}

sub get_model {
	return shift->{_MODEL};
}

sub on_SelectProfil_edit {
}

sub on_SelectProfil_delete {
}

sub set_update_SelectProfil {
	my ($this, $func) = @_;
	$this->{_UPDATE_SELECT_FUNC} = $func;
}

sub update_SelectProfil {
	shift->{_UPDATE_SELECT_FUNC}->();
}


1;

package Arborescence;
=pod
data
data/helicos/EC135/
data/pilotes.dat
=cut

#pour gérer les répertoires
use File::Spec;
use FindBin qw($RealBin);

sub get_base_dir {
	return $RealBin;
#	return main::get_base_dir;
}

use constant EDITEUR_FILE => 'editeur.dat';
use constant HELICO_FILE => 'helico.dat';
use constant CONFIG_FILE => 'config.dat';
use constant CARBURANT_FILE => 'carburant.dat';
use constant PROFILS_FILE => 'profils.dat';


use constant DATA_DIR => 'data';
use constant ODS_FILE => 'fichier.ods';
use constant ODS_DIR	=> File::Spec->catdir('utils','Ods');
use constant IMG_DIR => 'img';
use constant HELICOS_DIR => 'helicos';

#sub get_ my $dir = File::Spec->catdir($base_dir, HELICOS_DIR, $type_heli_dos,$heli_dos);

sub get_config_path {
}


=pod
Si $sHelico n'est pas fourni, le dossier et celui du type d'hélico
=cut
sub get_helico_dir {
	my ($sTypeHelico, $sHelico) = @_;

	my $sDir = File::Spec->catdir(get_base_dir, HELICOS_DIR, $sTypeHelico);

	my @dir = (get_base_dir, HELICOS_DIR, $sTypeHelico);
	push @dir, $sHelico if ($sHelico);

	return File::Spec->catdir(@dir);
}

sub get_helico_path {
	return File::Spec->catfile(get_helico_dir(@_), HELICO_FILE);
}

sub get_carburant_path {
	return File::Spec->catfile(get_helico_dir(@_), CARBURANT_FILE);
}

sub get_profils_path {
	return File::Spec->catfile(get_helico_dir(@_), PROFILS_FILE);
}

1;

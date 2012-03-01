package Config::Config::Controller;

use strict;

use constant KEY_CONFIG_NAMES	=> { 'config' => 'Config.keyfile'
										};
use constant HELICO_GROUP		=> 'helicos';
use constant TYPE_HELICO_GROUP	=> 'typehelicos';
use constant MDP_GROUP			=> 'mdp';

use Data::Dumper;

my $keyfile;
my $base_dir = main::get_base_dir();
my $config_string_dir = File::Spec->catdir($base_dir,Config::KeyFileManage::CONFIG_DIR,Config::KeyFileManage::KEYFILES_DIR);

$keyfile = Glib::KeyFile->new();
$keyfile->load_from_dirs(KEY_CONFIG_NAMES->{'config'}, 'keep-comments',$config_string_dir) or warn($@);
my @helicos = ();
my $helico_changed = 1;
my @typehelicos = ();
my $typehelico_changed = 1;

sub liste_helicos {
	if ($helico_changed == 1) {#si on a ajouté ou supprimé un hélico
		my @keys = $keyfile->get_keys(HELICO_GROUP);
		foreach my $key (@keys) {
			push @helicos, {nom => $key, type => $keyfile->get_string(HELICO_GROUP,$key)};
		}
		$helico_changed = 0;
	}
	Dumper(@helicos);
	return \@helicos;
}

sub liste_type_helicos {
	if ($typehelico_changed == 1) {
		my @keys = $keyfile->get_keys(TYPE_HELICO_GROUP);
		foreach my $key (@keys) {
			push @typehelicos, {type => $key, dossier => $keyfile->get_string(TYPE_HELICO_GROUP,$key)};
		}
		$typehelico_changed = 0;
	}
	return \@typehelicos;
}

sub add_helico {
	my $helico = shift;#{nom=>,type=>}
	$keyfile->set_string(HELICO_GROUP,$helico->{nom},$helico->{type});
	Config::KeyFileManage::write_to_file(['config',$keyfile]);
	$helico_changed = 1;
	liste_helicos();
}

sub add_type_helico {
	my $typehelico = shift;#{dossier=>,type=>}
	$keyfile->set_string(TYPE_HELICO_GROUP,$typehelico->{dossier},$typehelico->{type});
	Config::KeyFileManage::write_to_file(['config',$keyfile]);
	$typehelico_changed = 1;
	liste_type_helicos();
}

sub del_helico {
	my $helico = shift;#{nom=>}
	$keyfile->remove_key(HELICO_GROUP,$helico->{nom});
	Config::KeyFileManage::write_to_file(['config',$keyfile]);
	$helico_changed = 1;
	liste_helicos();
}

sub del_type_helico {
	my $typehelico = shift;#{type=>}
	$keyfile->remove_key(TYPE_HELICO_GROUP,$typehelico->{type});
	$typehelico_changed = 1;
	Config::KeyFileManage::write_to_file(['config',$keyfile]);
	liste_type_helicos();
}

sub get_mot_de_passe {
	my $type = shift;
	if ($type == 0) {
		return $keyfile->get_string(MDP_GROUP,'admin');
	} else {
		return $keyfile->get_string(MDP_GROUP,'super');
	}
}

sub find_dossier_by_type {
	return $keyfile->get_string(TYPE_HELICO_GROUP,shift);
}
sub find_type_by_dossier {
	my $dossier = shift;
	my @keys = $keyfile->get_keys(TYPE_HELICO_GROUP);
	foreach my $key (@keys) {
		my $value = $keyfile->get_string(TYPE_HELICO_GROUP,$key);
		if($value eq $dossier) {
			return $key;
		}
	}
	return undef;
}
1;
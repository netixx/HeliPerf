package Config::KeyFileManage;

use Glib;
use strict;
use File::Spec;
use Data::Dumper;

use constant CONFIG_DIR   	=> 'Config';
use constant KEYFILES_DIR	=> 'Keyfiles';
use constant KEY_FILE_NAMES => {
					'strings'		=> 'Strings.keyfile',
					'keys'			=> 'Keys.keyfile',
					'config'		=> 'Config.keyfile',
					'preferences'	=> 'Preferences.keyfile'
					};

use Config::Strings::Controller;
use Config::Preferences::Controller;
use Config::Config::Controller;

use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw(&get_strings &get_string);

my $base_dir = main::get_base_dir();

#my %hash = KEY_FILE_NAMES;
#my @files = keys %hash;

#my $strings = undef
#my $config_dir = File::Spec->catdir($base_dir,CONFIG_DIR);

sub get_strings {
	return Config::Strings::Controller::read_all_strings();
}

sub get_string {
	return Config::Strings::Controller::get_string(shift);
}

sub get_helicos {
	return Config::Config::Controller::liste_helicos();
}

sub get_typehelicos {
	return Config::Config::Controller::liste_type_helicos();
}

sub add_helico {
	Config::Config::Controller::add_helico(shift);
}

sub add_type_helico {
	return Config::Config::Controller::add_type_helico(shift);
}

sub del_helico {
	return Config::Config::Controller::del_helico(shift);
}

sub del_type_helico {
	return Config::Config::Controller::del_type_helico(shift);
}

sub get_mdp_admin {
	return Config::Config::Controller::get_mot_de_passe(0);
}
sub get_mdp_super {
	return Config::Config::Controller::get_mot_de_passe(1);
}
sub get_dossier_by_type {
	return Config::Config::Controller::find_dossier_by_type(shift);
}
sub get_type_by_dossier {
	return Config::Config::Controller::find_type_by_dossier(shift);
}
sub write_to_file {
	my $fileref = shift;
	my $keyfile_ref = $fileref->[0];
	my $keyfile_obj = $fileref->[1];
	my $file = $keyfile_obj->to_data() or warn ($@);
	my $filepath = File::Spec->catfile($base_dir,CONFIG_DIR,KEYFILES_DIR,KEY_FILE_NAMES->{$keyfile_ref});
	open (KEYFILE, '>', $filepath) or warn("Erreur lors de l'ouverture du fichier de configuration");
	print KEYFILE $file;
	close KEYFILE;
	return 1;
}
1;
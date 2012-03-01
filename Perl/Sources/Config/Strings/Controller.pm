package Config::Strings::Controller;

use strict;
use utf8;

use constant KEY_STRINGS_NAMES => {
					'strings'	=> 'Strings.keyfile',
					};
my $keyfile;
my $strings_cache = undef;
my $base_dir = main::get_base_dir();
my $config_string_dir = File::Spec->catdir($base_dir,Config::KeyFileManage::CONFIG_DIR,Config::KeyFileManage::KEYFILES_DIR);

=pod
@description
	recupère une clé particulière dans le fichier
=cut
sub get_string {
	if(!defined($keyfile)) {#si le fichier est deja chargé, on ne le recarge pas
		$keyfile = Glib::KeyFile->new;
		$keyfile->load_from_dirs(KEY_STRINGS_NAMES->{'strings'}, 'keep-comments',$config_string_dir) or warn($@);
	}
	my $content = shift;
	my $group = $content->[0];
	my $key = $content->[1];
	return $keyfile->get_string($group,$key);
	#if(defined($@)) {
	#	return "Pas de chaine dans le Keyfile : $@";
	#} else {
	#	return $strings_cache->{$group}{$key};
	#}
}

=pod
@description
	construit une reference vers un table de hachage contenant les chaines de caractères définies dans l'application
@return
	1) ref ->une reference vers un table de hachage : util:: $->{groupe dans le fichier}->{non de la clé}
=cut
sub read_all_strings {
	$keyfile = Glib::KeyFile->new();
	$keyfile->load_from_dirs(KEY_STRINGS_NAMES->{'strings'}, 'keep-comments',$config_string_dir) or warn($@);
	my @groups = $keyfile->get_groups();
	foreach my $group (@groups) {
		my @keys = $keyfile->get_keys($group);
		foreach my $key (@keys) {
			if (!defined($strings_cache->{$group}{$key})) {
				$strings_cache->{$group}{$key} = $keyfile->get_string($group,$key);
			}
		}
	}
	return $strings_cache;
}

sub to_keyfile {
	my $strings_changed = shift;
	my @groups = keys (%$strings_changed);
	foreach my $group (@groups) {
		my @keys = keys %{$strings_changed->{$group}};
		foreach my $key (@keys) {
			$keyfile->set_string($group,$key,$strings_changed->{$group}{$key});
			GenericWin::erreur([['erreur','key_file_write_fail']],$@) if(defined($@));
		}
	}
	Config::KeyFileManage::write_to_file(['strings',$keyfile]);
}
#write_to_file(['strings',$keyfile]);
=pod
@description
	réécrit le fichier de clés, valeurs en fonction des modifications faites
@param
	1)un tableau de string(issue des clés KEY_FILE_NAME), Glib keyfile

=cut

1;
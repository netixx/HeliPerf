package administration::exportWin::Export;

use strict;
use utf8;
use GenericWin;
use IO::Compress::Zip qw(zip $ZipError);
use File::Spec; use Cwd;
use Digest::SHA;
my $heli_dir;
my $base_dir;
#my $strings;
sub init {
	$heli_dir = shift;
	$base_dir = shift;
	#$strings = main::get_strings();
}
=pod
idem que importer mais avec exporter
=cut
sub exporter {
	chdir $heli_dir;
	#on recupere les infos sur l'helico à exporter par le chemin dans lequel il est sauvegardé
	my @tab = File::Spec->splitdir($heli_dir);
	my $heliname = pop(@tab);
	my $helitype = pop(@tab);
	my $path = GenericWin::filechooser([['titres','exporter']],'save','zip',$heliname.'.zip');
	archive($path,$heliname,$helitype);
}
#TODO: utiliser un buffer plutot que d'ecrire et de supprimer un fichier
=pod
@description
	Créé une archive .zip contenant toutes les informations pour l'importation
@param
	1)String->le chemin vers l'archive
	2)String->le nom de l'hélico
	3)String->son type
=cut
sub archive {
	my ($path,$heliname,$helitype) = @_;#on recupere le chemin de l'util, le nom et le type de l'heli
	if (defined($path) && defined($heliname) && defined($helitype)) {
		my $pathzip = File::Spec->catfile($heli_dir,$heliname.'zip.zip');#on crée un fichier zip avec tous les fichiers .dat
		zip [<*.dat>]	=>	$pathzip or GenericWin::erreur_msg([['erreurs','exporter_zip']]);
		my $sha = Digest::SHA->new(256);
		$sha->addfile($heliname.'zip.zip');#on calcule le sha
		my $shasum = $sha->hexdigest;#on ecrit le type, le nom et le sha dans un fichier caché (sur linux)
		open(my $resume, '+>:encoding(UTF-8)',".info.dat") or GenericWin::erreur_msg([['erreurs','exporter_descriptfile']]);
			print $resume "[TYPE]\n$helitype\n[NOM]\n$heliname\n[SHA]\n$shasum\n[CONTENT]\n";
		close $resume;
		#on re zip le tout
		my $files = ['.info.dat', $heliname.'zip.zip'];
		if ( zip $files => $path ) {
			my @tab = File::Spec->splitdir($path);
			pop(@tab);
			$path = File::Spec->catdir(@tab);
			#on supprime les fichiers tempo
			my $nfichier = unlink('.info.dat',$heliname.'zip.zip');
			if ($nfichier) {
				print "$nfichier\n";
			} else {
				GenericWin::erreur_msg([['erreurs','exporter_tempofile']],$!);
			}
			GenericWin::info([['titres','reussite'],['messages','exporter_success_main'],['messages','exporter_success_sub']],$path);
			return 1;
		} else {
			GenericWin::erreur_msg([['erreurs','exporter_fail']],$ZipError);
			return 0;
		}


	}
	return 0;
}
1;

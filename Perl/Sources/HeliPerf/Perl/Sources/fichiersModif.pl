#!/usr/bin/perl -w

use strict;
use warnings;

use constant RECURSIF					=> 1;
use constant START_DIR					=> '.';
use constant FICHIERS_MODIFIES			=> 'fichiers_modifiés.txt';
use constant DESC_FILE					=> '.fichiers_modifies.txt';
use constant FICHIERS_MODIFIES_BACKUP	=> 'fichiers_modifiés.old.txt';
use constant SCRIPT						=> 'fichiersModif.pl';
use constant SCRIPT_LINK				=> 'ckeck.pl';
use FindBin qw($RealBin);
use Digest::SHA;
use File::Path;
use File::Spec;

my $remote_dir;#le chemin vers le fichier distant à scanner
my $write_all;#dire s'il faut réecrire le fichier de description
my $sha = Digest::SHA->new(256);#utilisation du sha, algorythme 256 bits

my $quiet =0;#mode silencieux(pas de sortie)
my $shell = 0;#mode shell

use constant DEBUG 				=> 0;
use constant DEBUG_SCRIPT		=> 0;

my @fichiers = ();#tableau des fichiers de l'application

my @lib_paths = ('.');#chemin de départ

if (DEBUG){
    print "U3_DEVICE_PATH is u3_drive\n";
    print "$_ is a LIB path\n" for (@lib_paths);
}

my @dirs = ();

sub rec_trait {
	my @dirs = @_;
	my $dir = join('/', @dirs);

	#print "[$dir]\n";

	-d $dir or die "HALT: $_ not found ($!)\n";

	opendir THEDIR, $dir or die "HALT: Can't open $dir ($!)\n";
	my @lib_files = readdir THEDIR or die "HALT: Can't read $dir ($!)\n";
	close THEDIR;
	#boucle de lecture des fichiers recursivement

	for my $file (@lib_files){
		if ($file eq '.' || $file eq '..' || $file eq 'script.pl') { next; }

		my $lib_file = "$dir/$file";

		if (-d $lib_file) {
			#récursif ?
			rec_trait(@dirs, $file) if (RECURSIF);
		} elsif ($file =~ /(.pm|pl|xml|keyfile)$/) {
			$sha->reset();
			$sha->addfile($lib_file,'p');
			my $filedescriptor = $sha->hexdigest;
			push @fichiers, {desc => $filedescriptor, filename => substr($lib_file,2)};
		}
	}
}
traitement_parametre();
to_file();

sub to_file {
	my $nident = 0;
	my $ndiff = 0;
	chdir $RealBin;
	open(my $file,'>',FICHIERS_MODIFIES_BACKUP);
		open(my $backupfile,'<',FICHIERS_MODIFIES);
			my @lines = <$file>;
			print $backupfile @lines;
		close($backupfile);
	close($file);
	#my @req = ('mv',FICHIERS_MODIFIES,FICHIERS_MODIFIES_BACKUP);
	#system(@req);
	if ($write_all == 1) {#on réecrit le fichier descripteur
		open(my $THEDESCFILE,'>',DESC_FILE)  or die "HALT: Can't open FICHIERS_MODIFIES ($!)\n";
			foreach my $fichiermodif (@fichiers) {
				print $THEDESCFILE $fichiermodif->{filename};
				print $THEDESCFILE ';'.$fichiermodif->{desc}."\n";
			}
		close $THEDESCFILE;
		$write_all = 0;
		return ;
	} else {
		open(my $THEFILEFILE,'>',FICHIERS_MODIFIES)  or die "HALT: Can't open FICHIERS_MODIFIES ($!)\n";
			open( my $THEDESCFILE,'<', DESC_FILE)  or die "HALT: Can't open DESC_MODIFIES ($!)\n";
			print "ouverture\n" if (DEBUG);
			while (<$THEDESCFILE>) {
				print "Comparaison\n" if (DEBUG);
				my $line = $_;
				my @file = split (/;/,$line);
				chomp($file[1]);
				foreach my $fichier (@fichiers) {
					if ($file[0] eq $fichier->{filename}) {
						print "$file[0]\n$fichier->{filename}\n$file[1]\n$fichier->{desc}\n" if (DEBUG);
						if ($fichier->{desc} ne $file[1]) {
							print $THEFILEFILE $fichier->{filename}."\n";
							$ndiff++;
							print "!!!!!!!!Fichiers modifiés!!!!!!!!!\n" if (!$shell || !$quiet);
							print "\t\t\t" if ($shell || !$quiet);
							print "$fichier->{filename}\n" if(!$quiet);
						} else {
							$nident++;
						}
					}
				}
			}
			close $THEDESCFILE;
		close $THEFILEFILE;
		print "$ndiff fichiers ont été modifiés\n$nident fichiers n'ont pas été modifiés\n";
	}
}

sub traitement_parametre {
	if (defined($ARGV[0])) {
		if ($ARGV[0] eq '-r') {
			unlink DESC_FILE;
			print "Scan de base mis à jour\n";
			print "Suppression du fichier de descripteurs\n";
		}	elsif ($ARGV[0] eq '-i') {
			install()
		} elsif ($ARGV[0] eq '-purge') {
			purge();
		} elsif ($ARGV[0] eq '-shell') {
			$shell = 1;
			shell();
		} elsif ($ARGV[0] eq '-copy') {
			if (defined($ARGV[1])) {
				copy_to($ARGV[1])
			} else {
				die("Spécifiez un dossier valide\n"); exit;
			}
		} elsif ($ARGV[0] eq '-q') {
			$quiet = 1;
		} elsif ($ARGV[0] eq '-merge') {
			if (defined($ARGV[1])) {
				$remote_dir = $ARGV[1];
				compare();
			} else {
				print("Spécifiez un dossier disant\n");
			}
		}
	}
	if (!(-f SCRIPT_LINK)) {
		eval {symlinc(SCRIPT,SCRIPT_LINK);1} ;#ajout du lien symbolique s'il n'existe pas
	}
	print("Programme de fusion des fichiers\n") if (!$quiet);
	if (!(-f DESC_FILE)) {
		$write_all = 1;
		print "Le fichier de comparaison n'existe pas\n\t\t->>>Création en cours->>>\n";
	}#on réecrit le fichier s'il n'existe pas
	else {
		$write_all = 0;
	}

	rec_trait(START_DIR);
}

sub shell {
	print "\n\tshell->";
	my $command = <STDIN>;
	if (defined($command)) {
		chomp($command);
		if ($command eq 'help') {
			help();
		} elsif ($command eq 'show-changed') {
			if (scalar(@fichiers) == 0) {
				rec_trait(START_DIR);
				shell();
			} else {
				show_changed();
				shell();
			}
		} elsif ($command eq 'merge-dirs') {
			rec_trait(START_DIR);
			print("\ndossier ordinateur->");
			$remote_dir = <STDIN>;
			chomp($remote_dir);
			compare();
		} elsif ($command eq 'clean') {
			purge();
		} elsif ($command eq 'copy') {
			print "\t\t\tDossier->";
			my $dir = <STDIN>;
			copy_to($dir);
		} elsif ($command eq 'copy -o') {
			my $dir = <STDIN>;
			rmtree($dir);
			mkdir($dir);
			copy_to($dir);
		} elsif ($command eq 'exit') {
			exit;
		} elsif ($command eq 'execute') {
			rec_trait(START_DIR);
			shell();
		} elsif ($command eq 'install') {
			install();
		} elsif ($command eq 'export') {
			if (scalar(@fichiers) == 0) {
				rec_trait(START_DIR);
				shell();
			}
		to_file();
		print("Répertroire?->");
		my $dir = <STDIN>;
		copy_fichier('compare');
		copy_to($dir);
		} else {
			print("Commande invalide, tapez 'help' pour la liste des commandes valides\n");
			shell();
		}
	} else {

	}
}

sub reload_bashrc {
	chdir($ENV{HOME});
	my @bashreq = ('source',' ','\.bashrc');
	system(@bashreq);
	chdir($RealBin);
}

#montre l'aide
sub help {

	if ($shell) {
		shell();
	} else {
		exit;
	}
}

sub purge {
	my $param = shift;
	chdir $ENV{HOME}; print "Le repertoire home est :".$ENV{HOME}."\n" if (DEBUG_SCRIPT);
	open(my $bashrc, '<', ".bashrc") or warn "impossible d'ouvrir le fichier";
		my @lines = ();
		my $ndell = 0;
		while (<$bashrc>) {
			my $line = $_;
			my $lineraw = $line;
			chomp($line);
			print "$line\n" if (DEBUG_SCRIPT);
			if ($line eq "alias check='cd $RealBin;perl check.pl'") {#si une des ligne correspond
					print "Ligne supprimée\n" if (DEBUG_SCRIPT);#on l'enleve
					$ndell++;
			} else {
					push @lines, $lineraw; print "Ligne conservée\n" if (DEBUG_SCRIPT);
			}
		}
	close $bashrc;
	if ($ndell>0) {
		open($bashrc, '>', ".bashrc") or warn "impossible d'ouvrir le fichier";
			print $bashrc @lines or warn "ecriture impossible \n";
		close $bashrc;
		print "\t->>$ndell lignes ont été supprimées\n" unless (defined($param) && $param == 0);
	} else {
		print "Aucunes lignes supprimées, peut-être l'installation n'a pas été faite?\n \tExecutez -i ou install dans le shell pour y remedier\n" unless (defined($param) && $param == 0);
	}
	chdir $RealBin;
	unlink(SCRIPT_LINK,FICHIERS_MODIFIES,FICHIERS_MODIFIES_BACKUP,DESC_FILE) unless (defined($param) && $param == 0);
	#reload_bashrc
	if (defined($param) && $param == 0) {
		return 1;
	}
	if ($shell) {
		shell();
	} else {
		exit;
	}
}

sub install {
	purge(0);
	chdir $ENV{HOME};
	open(my $bashrc, '>>', "$ENV{HOME}/.bashrc");
		print $bashrc "alias check='cd $RealBin;perl check.pl'\n";
	close $bashrc;
	reload_bashrc();
	chdir $RealBin;
	print "Installation terminée\n";
	if ($shell) {
		shell();
	} else {
		exit;
	}
}

sub show_changed {
	open(my $file,'<',FICHIERS_MODIFIES) or warn("Impossible de lire le fichier");
	print <$file>;
	close $file;
	if ($shell) {
		shell();
	} else {
		exit;
	}
}

sub copy_to {
	my $dir = shift;
	chdir $dir or return 0;
	chdir $RealBin;
	system ("cp -r . $dir");
	if ($shell) {
		shell();
	} else {
		exit;
	}
}
sub copy_fichier {
	my $name = shift;
	chdir $RealBin;
	system ("cp FICHIERS_MODIFIES $name.'>'.FICHIERS_MODIFIES");
}

sub compare {
	$quiet = 1;
	rec_trait(START_DIR);
	$quiet = 0;
	chdir $remote_dir;
	my @req=("perl",SCRIPT,'-q');
	system(@req);
	chdir($RealBin);
	open(my $remotefile, '<', $remote_dir."/".FICHIERS_MODIFIES) or die("impossible d'afficher le fichier");
	my @remotefiles = <$remotefile>;
	close $remotefile;
	print("Début de la comparaison\n");
	chdir($RealBin);
	my @conflits;
	my @requete;
	open(my $fichiermodif, '<', FICHIERS_MODIFIES);
	my @fichiersmodif = <$fichiermodif>;
	close($fichiermodif);
	my $nconflit = 0;
	my $ncopies = 0;
	foreach my $remotefile (@remotefiles) {#parcours des fichiers modifiés de l'ordi distant
		chomp($remotefile);
		my $conflit = 0;
		foreach my $file (@fichiersmodif) {#parcours des fichiers modifiés de la clé
			chomp($file);
			if ($remotefile eq $file) {
				$conflit = 1;
			}
		}
		if ($conflit) {
			push @conflits, $remotefile;
			$nconflit++;
		} else {
			print("copie en cours->>\n");
			my @remote = split(/\//,$remotefile);
			my $filedir;
			if (scalar(@remote) == 1) {
				$filedir = '.';
			} else {
			pop @remote;
				$filedir = join('/',@remote);
			}
			$filedir .='/';
			@requete = ('cp',$remote_dir,'/',$remotefile,' ',$filedir);
			system(@requete);
			$ncopies++;
		}
	}
	foreach my $conflit (@conflits) {
		@requete=('vim diff', $remote_dir,'/',$conflit,' /',$conflit);
		system("vim -d $remote_dir/$conflit $conflit");
		print("\nQuel fichier faut-il conserver ?\n");
		print($remote_dir.'/'.$conflit." (1)\n");
		print($RealBin.'/'.$conflit." (2)\n");
		my $reponse = <STDIN>;
		chomp($reponse);
		if ($reponse == 1) {
			system("cp $remote_dir/$conflit .");
			print("Conservation du fichier de l'ordinateur\n");
		} else {
			print("Conservation du fichier mobile\n");
		}
	}
	print ("$ncopies fichiers ont été copiés\n$nconflit conflits ont été règlés\n");
	chdir($RealBin);
	system("find . -name \"*.swp\" -delete");
	system("find . -name \"*.komodoproject\" -delete");
	system("find . -name \"*.DS_Store\" -delete");
	system("cp -R * $remote_dir/");
	chdir($remote_dir);
	@req=("perl",SCRIPT,'-r');
	system(@req);
	chdir($RealBin);
	@req=("perl",SCRIPT,'-r');
	system(@req);
	print("Les dossiers sont à jour\n");
	exit;
}

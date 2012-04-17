package administration::adminWin::Controller;

use strict;
use utf8;
use Digest::SHA qw(sha1_hex);

use GenericWin;
#my $strings = main::get_strings();

=pod
description
	créée et affiche une boite de dialogue qui demande à l'utilisateur son mot de passe
return
	1 si le mot de passe et bon et que l'utilisateur appuie sur ok
	0 sinon
requires
	administration::ImportExport::importer|exporter|editer
=cut
sub adminwin {
	my ($mdpadminstore,$mdpsuperadminstore) = mainWin::Controller::get_mot_de_passe();#recupération du mot de passe
	my ($reponse,$mdp) = (2,"");#set de reponse à oui set de mdp a null
	while ($reponse != 0) {#tant qu'il n'appuie pas sur annuler
		if ( $mdp eq $mdpadminstore && $reponse ==1) {#verification du mot de passe avec celui dans config.dat
			return (1,'admin');#on poursuit si c'est le même (arret de la boucle)
		} elsif ($mdp eq $mdpsuperadminstore && $reponse == 1) {
			return (1,'super');
		} elsif ( $mdp ne $mdpadminstore && $mdp ne $mdpsuperadminstore && $reponse == 1) {
			GenericWin::erreur_msg([['messages','mdp_bad_main'],['messages','mdp_bad_sub']]);
		}
		($mdp,$reponse) = GenericWin::entreetext([['messages','mdp_req_main'],['messages','mdp_req_sub'],['titres','mdp']]);#demande de mot de passe et de la reponse
		$mdp = sha1_hex($mdp) if (defined($mdp));#sha du mot de passe pour comparaison
	}
	return (0,undef);#si l'utilisateur appuie sur annuler
}
1;

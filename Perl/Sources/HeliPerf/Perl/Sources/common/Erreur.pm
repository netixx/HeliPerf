package Erreur;
=pod
@description
	permet de créer une boite de dialogue de type erreur
@list
	msg,end
=cut

use utf8;

my $window;
#fonction appellé par main au demmarrage
sub init {
  $window = shift; #recueration de la fenetre parent helimasse0
}

=pod
@description
	créée une boite de dialog avec un message principal et un message secondaire
@param
	1)String->message d'erreur principal
	2)String (optional)->message d'errueur secondaire eventuel
@return
	1
=cut
sub msg {
  my ($msgprinc,$msgsecond) = @_;
  my $diagerreur = Gtk2::MessageDialog->new ($window,
                                  'modal',
                                  'error',
                                  'close',
                                  $msgprinc);# création de la boite de dialoge
  $diagerreur->format_secondary_text($msgsecond) if (defined($msgsecond));#parametrage eventuel du message secondaire
  $diagerreur->run;#ouvertur de la fenetre d'erreur
  $diagerreur->destroy;#fermeture de la fenetre
  return 1;
}

=pod
@description
	créée une boite de dialog avec un message principal et un message secondaire et quite le programme
@param
	1)String->message d'erreur principal
	2)String (optional)->message d'errueur secondaire eventuel
@return
	->fin du programme
=cut
sub end {
  my ($msgprinc,$msgsecond) = @_;
  msg ($msgprinc,$msgsecond);  
  exit(-1);#fermeture du programme
}

1;

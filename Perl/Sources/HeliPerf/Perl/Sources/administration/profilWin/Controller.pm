package administration::profilWin::Controller;

use strict;

use administration::profilWin::widgets::SelectProfil;
use administration::profilWin::widgets::Profil;

use administration::profilWin::Controller::Categorie;
#use administration::profilWin::Controller::Profil;

use constant EDIT_FILE	=> 'editeur.dat';
use constant PROFILS_FILE => 'profils.dat';

use constant NOUVEAU_PROFIL_NAME => 'Nouveau profil';

my $profils;
my $categories;
my $nth;
my %liste_ids;

sub init {
	my ($editprofil_name, $profil_listmatos, $profil_notebook, $label,$treeselprofview) = @_;
	administration::profilWin::widgets::SelectProfil::init($treeselprofview);
	administration::profilWin::widgets::Profil::init( $editprofil_name, $profil_listmatos, $profil_notebook, $label);
}

sub show {
	my $is_editable = shift;
	$categories = file::Editeur::load(EDIT_FILE) || [];
	$profils = file::Profils::load(PROFILS_FILE);
	%liste_ids = ();

	#for (my $i = 0; $i <= $#$profils; $i++) {
		##map { $_ = administration::profilWin::Controller::Profil->new($_)} @$profils;
		#$profils->[$i] = administration::profilWin::Controller::Profil->new($profils->[$i]);
	#}
	#my @cProfils = map { administration::profilWin::Controller::Profil->new($_)} @$profils;

	administration::profilWin::widgets::SelectProfil::new($categories, $profils, $is_editable);
	#administration::profilWin::widgets::SelectProfil::new($categories, \@cProfils, $is_editable);
}


sub on_SelectProfil_edit {
	#my ($categories, $profils, $nth_arg) = @_;
	my ($nth_arg) = @_;
	$nth = $nth_arg;
	edit_profil($profils->[$nth]);
	#my @catControllers = map { administration::profilWin::Controller::Categorie->new($_)  } @$categories;

	#my $func = sub {
		#my $profil = shift;
		#$profils->[$nth] = $profil;
		#file::Profil::save($profils);
	#};

	#administration::profilWin::widgets::Profil::construct($profils->[$nth], \@catControllers);#, $func);

}

sub on_SelectProfil_delete {
	my $nth_arg = shift;
	splice(@$profils, $nth_arg, 1);
	save_profils();
}

sub edit_profil {
	my $profil = shift;

	my @catControllers = map { administration::profilWin::Controller::Categorie->new($_)  } @$categories;

	#my $func = sub {
		#my $profil = shift;
		#$profils->[$nth] = $profil;
		#file::Profil::save($profils);
	#};

	administration::profilWin::widgets::Profil::construct($profil, \@catControllers);#, $func);
}

sub save_profils {
	file::Profils::save(PROFILS_FILE, $profils);
}


sub ajoute_to_profil {
	my $id = shift;
	$liste_ids{$id} = $id;
}

sub enleve_to_profil {
	my $id = shift;
	delete ($liste_ids{$id});
}

sub save {
	$profils->[$nth]->set_ids([values(%liste_ids)]);
	$profils->[$nth]->set_nom(administration::profilWin::widgets::Profil::get_nom);
	save_profils;
	show();
}

sub ajouter_profil {
	my $profil = models::Profil->new(NOUVEAU_PROFIL_NAME, []);
	#my $n = scalar(@$profils);
	$nth = scalar(@$profils);
	$profils->[$nth] = $profil;
	administration::profilWin::widgets::SelectProfil::ajoute($profil);
	#on_SelectProfil_edit($n);
	save_profils;
	edit_profil($profil);
}

1;

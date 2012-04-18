package administration::editWin::Controller;

use strict;

use administration::editWin::widgets::OngletsMatos;
use calcul::Centrage;
use file::Editeur;


use constants::File;
use constant EDITEUR_FILE	=> 'editeur.dat';
use constant PROFILS_FILE => 'profils.dat';
use constant HELICO_FILE => 'helico.dat';

my $win_name;

sub init {
	my ($notebook, $winname, $spinmasse, $spinbras) = @_;
	$win_name = $winname;
	administration::editWin::widgets::OngletsMatos::init($notebook, $spinmasse, $spinbras);
}

sub show {
	my $base = file::Editeur::load(EDITEUR_FILE) || [];
	my $profils = file::Profils::load(PROFILS_FILE) || [];
	my $helico = file::Helico::load(HELICO_FILE);
	OpenandCloseWin::construct_and_display($win_name);
	administration::editWin::widgets::OngletsMatos::new($base, $profils, $helico->get_bras_masse_pesee, $helico->get_config_base);
}

sub save {
	my ($categories, $profils) = administration::editWin::widgets::OngletsMatos::get_base;

	my $helico = file::Helico::load(HELICO_FILE);

	my @bras_masse = administration::editWin::widgets::OngletsMatos::get_bras_masse_pesee;
	my $config_base = administration::editWin::widgets::OngletsMatos::get_config_base;

	$helico->set_bras_masse_pesee(@bras_masse);

	$helico->set_config_base($config_base);
	 #calcul de la vraie masse à vide avec la config de base
	
	foreach my $categorie (@$categories) {
		foreach my $item (@{$categorie->get_items}) {
			# si c'est un regroupement, seul la présence en pesée de ses items testée
			if (scalar (@{$item->get_items})) {
				foreach my $sitem(@{$item->get_items}) {
					if ($sitem->is_present_pesee) {
						@bras_masse = calcul::Centrage::enleve_masse(@bras_masse, $sitem->get_bras_masse);
					}
				}
			}
			elsif ($item->is_present_pesee) {
				@bras_masse = calcul::Centrage::enleve_masse(@bras_masse, $item->get_bras_masse);
			}
		}
	}

	# ceci est la vraie masse à vide (sans la config de base)
	my @bras_masse_vide = @bras_masse;

	foreach my $item (@$config_base) {
		if (scalar (@{$item->get_items})) {
			foreach my $sitem(@{$item->get_items}) {
				if ($sitem->is_present_pesee) {
					@bras_masse_vide = calcul::Centrage::enleve_masse(@bras_masse_vide, $sitem->get_bras_masse);
				}
				else {
					@bras_masse = calcul::Centrage::ajoute_masse(@bras_masse, $sitem->get_bras_masse);
				}
			}
		}
		else {
			if ($item->is_present_pesee) {
				@bras_masse_vide = calcul::Centrage::enleve_masse(@bras_masse_vide, $item->get_bras_masse);
			}
			else {
				@bras_masse = calcul::Centrage::ajoute_masse(@bras_masse, $item->get_bras_masse);
			}
		}
	}

	$helico->set_bras_masse (@bras_masse);
	$helico->set_bras_masse_vide (@bras_masse_vide);

	file::Editeur::save(EDITEUR_FILE, $categories);
	file::Helico::save(HELICO_FILE, $helico);
	file::Profils::save(PROFILS_FILE, $profils);
}

sub add_item {
	administration::editWin::widgets::OngletsMatos::ajoute_item;
}

sub add_group {
	administration::editWin::widgets::OngletsMatos::ajoute_groupe;
}

1;

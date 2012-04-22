package administration::ajouterWin::widgets::OngletsMatos;

use Arborescence;

sub new {
	my $class = shift;
	my $this = { _N_CENTRAGE    => Gtk2::Notebook->new,
	             _N_CONFIGBASE  => Gtk2::Notebook->new,
		     _N_PESEE       => Gtk2::Notebook->new,
		     _PROFILS       => [],
		     _TYPE_APP      => ""
		     };
	return bless($this, $class);
}

sub set_type_appareil {
	my ($this, $sType) = @_;
	my $categories = file::Editeur::load(Arborescence::get_categories_path($sType)) || [];
	my $profils = file::Profils::load(Arborescence::get_profils_path($sType)) || [];
	$this->{_TYPE_APP} = $sType;
	$this->set_categories_profils($categories, $profils);
}

use Data::Dumper;
sub set_categories_profils {
	my ($this, $categories, $profils) = @_;

	$this->{_PROFILS} = $profils;

	my $n = $this->{_N_CENTRAGE}->get_n_pages;

	# en attendant les catégories fixes
	if (!$n) {
		$this->_init_notebooks($categories);
	}

	$n = $this->{_N_CENTRAGE}->get_n_pages;

	$treestores = administration::widgets::ListeOptionnels::categories_to_treestores($categories, $profils);

	for (my $i = 0; $i < $n; $i++) {
		get_treeview_from_tab($this->{_N_CENTRAGE  }, $i)->set_model($treestores->[$i]);
		get_treeview_from_tab($this->{_N_CONFIGBASE}, $i)->set_model($treestores->[$i]);
		get_treeview_from_tab($this->{_N_PESEE     }, $i)->set_model($treestores->[$i]);
	}
}

sub get_notebook_centrage {
	return shift->{_N_CENTRAGE};
}

sub get_notebook_configbase {
	return shift->{_N_CONFIGBASE};
}

sub get_notebook_present_pesee {
	return shift->{_N_PESEE};
}

sub _init_notebooks {
	my ($this, $categories) = @_;

	foreach my $categorie (@$categories) {
		$this->{_N_CENTRAGE  }->append_page (_new_scrolled_win(administration::widgets::ListeOptionnels::treeview_centrage     ), $categorie->get_nom);
		$this->{_N_CONFIGBASE}->append_page (_new_scrolled_win(administration::widgets::ListeOptionnels::treeview_configbase   ), $categorie->get_nom);
		$this->{_N_PESEE     }->append_page (_new_scrolled_win(administration::widgets::ListeOptionnels::treeview_present_pesee), $categorie->get_nom);
	}

	$this->{_N_CENTRAGE  }->show_all;
	$this->{_N_CONFIGBASE}->show_all;
	$this->{_N_PESEE     }->show_all;
}

sub _new_scrolled_win {
	my $win = administration::widgets::ListeOptionnels::scrolled_window(@_);
#	$win->show_all;
	return $win;
}

sub save {
	my $this = shift;
	my $categories = $this->get_categories;
	calcul::Id::auto_update_cat_profils($categories, $this->{_PROFILS});

	#en attendant arborescence
	file::Editeur::save(Arborescence::get_categories_path($this->{_TYPE_APP }), $categories);
	file::Profils::save(Arborescence::get_profils_path($this->{_TYPE_APP}), $this->{_PROFILS});
}


sub get_categories {
	my $this = shift;

	my @categories = ();

	my $notebook = $this->{_N_CENTRAGE};

	my $n = $notebook->get_n_pages;
	for (my $i = 0; $i < $n; $i++) {
		my $treestore = get_treeview_from_tab($notebook, $i)->get_model;
		my $lbl = get_label_from_tab($notebook, $i);
		my $items = administration::widgets::ListeOptionnels::treestore_to_items($treestore);
		push @categories, models::Categorie->new($lbl, \@items);
	}

	return \@categories;
}

sub get_treeview_from_tab {
	my ($notebook, $page) = @_;
	#scrolledwindow contient le treeview
	return $notebook->get_nth_page($page)->child;
}

sub get_label_from_tab {
	my ($notebook, $page) = @_;
	return $notebook->get_tab_label_text($notebook->get_nth_page($page));
}

=pod
@param $notebook
=cut
sub ajoute_groupe {
	administration::ajouterWin::ajoute_group(_get_current_treeview(@_));
}

=pod
@param $notebook
=cut
sub ajoute_item {
	administration::ajouterWin::ajoute_item(_get_current_treeview(@_));
}

=pod
@param $notebook
=cut
sub _get_current_treeview {
	my $notebook = shift;
	return $notebook->get_nth_page($notebook->get_current_page)->child;
}

1;

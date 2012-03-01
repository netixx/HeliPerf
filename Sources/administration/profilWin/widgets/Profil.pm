package administration::profilWin::widgets::Profil;

use strict;

my $wOnglets;
my $wListeMatos;
my $wLabel;
my $sWindowName;

sub init {
	my ($window_name, $treestore, $notebook, $label) = @_;
	$sWindowName = $window_name;
	$wOnglets    = common::widgets::Onglets->new($notebook);
	$wListeMatos = common::widgets::ListeMatos->new($treestore);
	$wLabel      = $label;
}

sub construct {
	my ($profil, $categories) = @_;
	OpenandCloseWin::construct_and_display($sWindowName);

	$wLabel->set_text($profil->get_nom);

	$wOnglets->set_categories(\@$categories);
	$wListeMatos->set_categories(\@$categories);
	
	my @tab_items = ();

	my $store_func = sub {
		my $cItem = shift;
		@tab_items[$cItem->get_model->get_id] = $cItem;
	};

	map { map { $store_func->($_)  } @{$_->get_items} } @$categories;

	foreach my $id (@{$profil->get_ids}) {
		if ($tab_items[$id]) {
			$tab_items[$id]->activate_Onglets();
		}
		else {
			print "$id\n";
		}
	}
}

sub get_nom {
	return $wLabel->get_text();
}

1;

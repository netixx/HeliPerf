package calcul::Id;

use constant ID_INIT => 0;

sub auto_set_categories {
	my $categories = shift;
	my $id = ID_INIT;

	foreach my $categorie (@$categories) {
		foreach my $item (@{$categorie->get_items}) {
			$id = incr_item($item, $id);
		}
	}
}

sub auto_update_cat_profils {
	my ($categories, $profils) = @_;
	my @table = ();

	my $id = ID_INIT;

	foreach my $categorie (@$categories) {
		foreach my $item (@{$categorie->get_items}) {
			$table[$item->get_id] = $id;
			$id = incr_item($item, $id);
		}
	}

	foreach my $profil (@$profils) {
		my @ids = ();
		foreach my $id (@{$profil->get_ids}) {
			push @ids, $table[$id] if defined($table[$id]);
		}
		$profil->set_ids(\@ids);
	}
}

sub incr_item {
	my ($item, $id) = @_;
	$item->set_id($id);
	return $id++;
}

1;

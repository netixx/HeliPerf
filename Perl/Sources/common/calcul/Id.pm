package calcul::Id;

sub auto_set_categories {
	my $categories = shift;
	my $id = 0;

	foreach my $categorie (@$categories) {
		foreach my $item (@{$categorie->get_items}) {
			$item->set_id($id);
			$id++;
		}
	}

}

1;

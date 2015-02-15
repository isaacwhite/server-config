class personal::domain_config {

	# pull values out of hiera
	$domains = hiera('sites')

	# if we have domains to create (we will) create them
	if ($domains) {
		create_resources(personal::types::domain, $domains)
	}

}
class personal::config::domains {

	# pull values out of hiera
	$domains = hiera_hash('sites')

	$required_dirs = ['/var', '/var/www' ]

	$owner = $personal::params::owner
	$group = $personal::params::group

	file { $required_dirs:
		ensure => directory,
		mode => '755',
		owner => $owner,
		group => $group
	}

	# if we have domains to create (we will) create them
	if ($domains) {
		create_resources(personal::types::domain, $domains)
	}

}
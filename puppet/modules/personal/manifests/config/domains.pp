class personal::config::domains {

	# pull values out of hiera
	$domains = hiera_hash('sites')

	$required_dirs = ['/var', '/var/www' ]

	file { $required_dirs:
		ensure => directory,
		mode => '755',
		owner => $personal::params::username,
		group => 'nginx',
	}

	# if we have domains to create (we will) create them
	if ($domains) {
		create_resources(personal::types::domain, $domains)
	}

}
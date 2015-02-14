define personal::types::domain (	
	$name = $title,
	$subdomains,
	$git,
	$database,
	$files
	) {

	# we'll use the sites definition here
	include personal::types::site

	$web_root = '/var/www/'
	$domain_base = "${web_root}${name}"
	
	file { $domain_base:
		ensure => directory,
	}

	# the site definition knows to add public_html
	peronal::types::site { $name:
		git => $git,
		database => $database,
		files => $files,
		root => $domain_base,
	}

	if $subdomains {

		$subdomain_path = "${domain_base}/subdomains/"

		# now we need to loop through subdomains, processing each of their names to account for parent
		each($subdomains) |$subdomain_name, $values| {

			# create a site for each one placing the root
			# inside the parent site root
			personal::types::site { "${subdomain_name}.{name}":
				git => $values['git'],
				database => $values['database'],
				files => $values['files'],
				root => "${subdomain_path}${subdomain_name}",
				require => Site[$name],
			}
		}
	}
}
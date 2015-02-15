define personal::types::domain (	
		$domain_name = $title,
		$subdomains = undef,
		$git = undef,
		$database = undef,
		$files = undef,
	) {

	$web_root = '/var/www/'
	$domain_base = "${web_root}${domain_name}"

	# the site definition knows to add public_html
	personal::types::site { $domain_name:
		git => $git,
		database => $database,
		files => $files,
		root => $domain_base,
	}

	if $subdomains {

		$subdomain_path = "${domain_base}/subdomains/"

		file {$subdomain_path:
			ensure => directory,
			require => Personal::Types::Site[$domain_name]
		}

		# now we need to loop through subdomains, processing each of their names to account for parent
		each($subdomains) |$subdomain_name, $values| {

			# create a site for each one placing the root
			# inside the parent site root
			personal::types::site { "${subdomain_name}.${domain_name}":
				git => $values['git'],
				database => $values['database'],
				files => $values['files'],
				root => "${subdomain_path}${subdomain_name}",
				require => Personal::Types::Site[$domain_name],
			}
		}
	}
}
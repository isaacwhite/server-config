define personal::types::domain (	
		$domain_name = $title,
		$subdomains = undef,
		$git = undef,
		$database = undef,
		$files = undef,
	) {

	$web_root = '/var/www/'
	$domain_base = "${web_root}${domain_name}"
	
	# params
	$username = $personal::params::username
	$owner = $personal::params::owner
	$group = $personal::params::group


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
			require => Personal::Types::Site[$domain_name],
			owner => $owner,
			group => $group,
		}

		# now we need to loop through subdomains, processing each of their names to account for parent
		if is_hash($subdomains) {

			each($subdomains) |$subdomain_name, $obj| {


				# $git_config = undef
				if is_hash($obj) {

					$git_config = $obj["git"]
					$db_config = $obj["database"]
					# $db_config = undef

					# create a site for each one placing the root
					# inside the parent site root
					personal::types::site { "${subdomain_name}.${domain_name}":
						git => $git_config,
						database => $db_config,
						files => $obj['files'],
						root => "${subdomain_path}${subdomain_name}",
						require => Personal::Types::Site[$domain_name],
					}
					
				} else {
					notify {"subdomain ${subdomain_name} for ${domain_name} is not a hash!": 
						loglevel => 'warning',
					}
				}
			}
		} else {
			notify {"subdomain for ${domain_name} is not a hash!": 
				loglevel => 'warning',
			}
		}
	}
}
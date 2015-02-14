define personal::types::site (
		$name = $title,
		$git,
		$database,
		$files,
		$root,
	) {

	$public = "${root}/public_html"
	# a sensible default
	$php = false

	file { $public:
		ensure => directory,
	}

	# one git repo per site
	if ($git) {
		personal::types::git { $name:
			remote => $git,
			destination => $public,
		}
	}

	# one database per site
	if ($database) {
		$access = hiera('access')
		personal::types::database { $database['name']:
			source => $database['source'],
		}

		$php = true
	}

	if ($files) {
		each($files) |$bucket_name, $values| {
			# we need to loop through all files renaming them with the $name property
			personal::types::extraction { "${name}${bucket_name}":
				source => $values['source'],
				destination => $public,
				path => $values['path']
			}
		}
	}

	# provide the nginx vhost for the site
	personal::types::vhost { $name:
		php => $php,
		path => $public,
	}
}
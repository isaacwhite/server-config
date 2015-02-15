define personal::types::site (
		$site_name = $title,
		$git = undef,
		$database = undef,
		$files = undef,
		$root = undef,
	) {

	$public = "${root}/public_html"
	$required_dirs = [$root, $public]

	file { $required_dirs:
		ensure => directory,
	}

	# one git repo per site
	if ($git) {
		notify {"${site_name} git creation stub":

		}
		# personal::types::git { $site_name:
		# 	remote => $git,
		# 	destination => $public,
		# }
	}

	# one database per site
	if ($database) {

		notify {"triggering database import for: ${database}": }
		# personal::types::database { $database: }

		$php = true
	} else {
		$php = false
	}

	if ($files) {
		each($files) |$bucket_name, $values| {
			# we need to loop through all files renaming them with the $name property
			$aws_config = hiera('aws')
			$files_dir = $aws_config['binary']['local']
			$filename = $values['source']
			$source = "${files_dir}/${filename}"

			personal::types::extraction { "${site_name}${bucket_name}":
				source => $source,
				destination => $public,
				path => $values['path']
			}
		}
	}

	# provide the nginx vhost for the site
	personal::types::vhost { $site_name:
		php => $php,
		path => $public,
	}
}
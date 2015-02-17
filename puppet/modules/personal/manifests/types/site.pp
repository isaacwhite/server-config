define personal::types::site (
		$site_name = $title,
		$git = undef,
		$database = undef,
		$files = undef,
		$root = undef,
		$auth = undef,
	) {

	$public = "${root}/public_html"
	$required_dirs = [$root, $public]

	file { $required_dirs:
		ensure => directory,
	}

	# one git repo per site
	if ($git) {

		$remote = $git['remote']
		$branch = $git['branch']
		
		personal::types::clone { $site_name:
			repo => $git,
			branch => $git_branch,
			path => $public,
		}
	}

	# one database per site
	if ($database) {
		# do php configs
		$php = true

		# pull out private data for database creation
		$access = hiera('access')
		$db_name = $database['name']
		$db_password = $access['databases'][$db_name]['password']
		$drupal_hash = $access['drupal']['hash']

		# create the db import
		personal::types::database { $database['name']:
			source => $database['source'],
			password => $db_password,
		}

		# save database connection settings after git clone done
		file { "${public}/sites/default/settings.php":
			ensure => file,
			mode => '440',
			content => template('personal/settings_php'),
			require => Personal::Types::Clone[$site_name]
		}

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
		auth => $auth,
	}
}
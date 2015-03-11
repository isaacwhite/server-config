define personal::types::site (
		$site_name = $title,
		$git = undef,
		$database = undef,
		$files = undef,
		$root = undef,
		$cron = undef,
	) {

	$owner = $personal::params::owner
	$group = $personal::params::group

	$public = "${root}/public_html"
	$required_dirs = [$root, $public]
	# pull out any required private data
	$access = hiera_hash('access')
	$auth = $access['auth'][$site_name]

	file { $required_dirs:
		ensure => directory,
		owner => $owner,
		group => $group,
		mode => '0775',
	}

	# one git repo per site
	if ($git) {

		$remote = $git['remote']
		$branch = $git['branch']
		
		personal::types::clone { $site_name:
			remote => $git['remote'],
			branch => $git['branch'],
			path => $public,
		}
	}

	# one database per site
	if ($database) {
		# do php configs
		$php = true

		# pull out private data for database creation
		$db_name = $database['name']
		$db_password = $access['databases'][$db_name]['password']
		$drupal_hash = $access['drupal']['hash']

		# create the db import
		personal::types::database { $database['name']:
			source => $database['source'],
			password => $db_password,
		}

		$sites_dir = "${public}/sites/default"
		# save database connection settings after git clone done
		file { "${sites_dir}/settings.php":
			ensure => file,
			content => template('personal/settings_php.erb'),
			owner => $owner,
			group => $group,
			mode => '440',
			require => [
				Personal::Types::Clone[$site_name],
			    Package['nginx'],
			],
		}

		$system_dirs = [
			"${sites_dir}/files",
			"${sites_dir}/private",
			"${sites_dir}/temp",
			"${public}/cache",
		]

		file { $system_dirs:
			ensure => directory,
			recurse => true,
			owner => $owner,
			group => $group,
			mode => '775',
			require => [
				Personal::Types::Clone[$site_name],
				Package['nginx'],
			]
		}

	} else {
		$php = false
	}

	if $files {
		each($files) |$bucket_name, $values| {
			# we need to loop through all files renaming them with the $name property
			$aws_config = hiera('aws')
			$files_dir = $aws_config['binary']['local']
			$filename = $values['source']
			$source = "${files_dir}/${filename}"

			personal::types::extraction { "${site_name} ${bucket_name}":
				source => $source,
				destination => $public,
				path => $values['path'],
				require => Personal::Types::Clone[$site_name]
			}
		}
	}
	$uri = $vm_environment ? {
		'staging' => "stg.${site_name}",
		'sandbox' => "sbx.${site_name}",
		default => $site_name,
	}

	if $cron and $vm_environment == 'production' {
		
		cron {"${site_name} cron":
			command => "/usr/bin/drush --uri=${uri} --root=${public} --quiet elysia-cron",
			user => 'nginx',
			minute => $cron['minutes'],
			hour => $cron['hours'],
		}

	}

	# provide the nginx vhost for the site
	personal::types::vhost { $site_name:
		php => $php,
		path => $public,
		auth => $auth,
	}
}
class personal::files_config {

	$aws_data = hiera()
	# require all aws file downloads before file extraction
	Aws_file <| |> -> File_extract <| |>

	$aws_cred_path = '/.aws_creds'
	$db_location = '/var/www/dbs'
	$img_location ='/var/www/imgs'

	file {$aws_cred_path:
		ensure => present,
		content => template('personal/aws_credentials.erb'),
		mode => 644,
	}

	# db downloads
	file {$db_location:
		ensure => directory,
		mode => 755,
	}

	aws_file {'db_dumps':
		local_path => "${db_location}",
		remote_path => "/dbs",
		after => File[$db_location],
	}

	# image downloads
	file {$img_location:
		ensure => directory,
		mode => 755,
	}

	aws_file {'images':
		local_path => "${img_location}",
		remote_path => "/files",
		after => File[$img_location],
	}

	# define an aws_file resource
	define aws_file (
		$direction = 'down',
		$local_path,
		$remote_path,
		$after,
		$bucket = "s1.isaacwhite.com",
	) {
		$s3_prefix = "s3://${bucket}"
		$key = 'MY_KEY'
		$secret = 'I\'m a secret ;)'

		if $direction == 'down' {
			$from = "${s3_prefix}${remote_path}"
			$to = $local_path
		} else {
			$to = "${s3_prefix}${remote_path}"
		}


		exec {"aws s3 sync ${from} ${to}":
			logoutput => true,
			environment => [
				"AWS_ACCESS_KEY_ID=${key}",
				"AWS_SECRET_ACCESS_KEY=${secret}",
			],
			path => '/usr/bin',
			require => [$after, 
						Package['awscli']
					]
		}

	}

	define file_extract (
		$source,
		$destination,
		$which = 'gzip'
	) {

		# allow both gzip and tar.gz
		if ($which == 'gzip') {
			exec {"gunzip -c $source > $destination":
				path => '/usr/bin',
				require => Package['gzip'],
			}
		} else {
			exec {"tar -xfz ${source} -C $destination":
				path => '/usr/bin',
				require => Package['tar'],
			}
		}
	}
}

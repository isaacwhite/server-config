define personal::types::sync (
	$remote,
	$local,
	$direction = 'down'
	) {


	# read from private hiera data
	$access = hiera_hash('access')
	# pull out keys
	$s3_key = $access['aws']['access']
	$s3_secret = $access['aws']['secret']
	$bucket = $access['aws']['bucket']

	# prepare for exec
	$s3_prefix = "s3://${bucket}"

	if $direction == 'down' {
		$from = "${s3_prefix}${remote}"
		$to = $local
	} else {
		$from = local
		$to = "${s3_prefix}${remote}"
	}

	ensure_resource('file', $local, {
		ensure => directory,
		mode => '775',
	})

	# download from s3
	exec {"aws s3 sync ${from} ${to}":
		logoutput => true,
		environment => [
			"AWS_ACCESS_KEY_ID=${s3_key}",
			"AWS_SECRET_ACCESS_KEY=${s3_secret}",
		],
		path => '/usr/bin',
		require => [
					File["${local}"], 
					Package['awscli']
				]
	}
}
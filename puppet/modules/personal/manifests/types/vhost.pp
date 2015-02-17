define personal::types::vhost (
		$vhost_name = $title,
		$path,
		$deny_hidden = true,
		$gzip = true,
		$php = false,
		$auth = false,
	) {

		# determine what to actually call this subdomain
		if $fqdn == 'GLaDOS-local' {
			$with_env = "sbx.${vhost_name}"
		} else {
			$with_env = $vhost_name
		}

		# do a regex to see if it contains more
		# than one period instead of passing param
		$is_subdomain = $vhost_name =~ /\S+\.\S+\.\S+/
		$redirect_to_www = !$is_subdomain

		# if we're a subdomain, we should do another substitution here
		if $is_subdomain {
			$server_name = $with_env
			# take out the subdomain string and period
			$parent_domain = regsubst($vhost_name, "^\S+\.", "")
		} else {
			$server_name = "www.${with_env}"
		}

		file { "${vhost_name} vhost":
			path => '/etc/nginx/sites-available/${vhost_name}',
			ensure => file,
			require => Package['nginx'],
			content => template('personal/nginx_vhost'),
		}

		# Symlink our vhost in sites-enabled to enable it
		file { "${vhost_name} vhost enable":
			path => '/etc/nginx/sites-enabled/${vhost_name}',
			target => '/etc/nginx/sites-available/${vhost_name}',
			ensure => link,
			notify => Service['nginx'],
			require => [
				File["${vhost_name} vhost"],
			],
		}
	}
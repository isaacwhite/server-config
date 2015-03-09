define personal::types::vhost (
		$vhost_name = $title,
		$path,
		$deny_hidden = true,
		$gzip = true,
		$php = false,
		$auth = undef,
	) {

		# determine what to actually call this subdomain
		$username = $personal::params::username
		$with_env = $vm_environment ? {
			'sandbox' => "sbx.${vhost_name}",
			'staging' => "stg.${vhost_name}",
			default => $vhost_name,
		}

		# do a regex to see if it contains more
		# than one period instead of passing param
		$is_subdomain = $vhost_name =~ /\S+\.\S+\.\S+/
		$redirect_to_www = !$is_subdomain

		# if we're a subdomain, we should do another substitution here
		if $is_subdomain {
			# take out the subdomain string and period
			$without_sub = regsubst($vhost_name, '^\w+\.', "")
			$parent_domain = $vm_environment ? {
				'sandbox' => "sbx.${without_sub}",
				'staging' => "stg.${without_sub}",
				default => $without_sub,
			}
			# don't add www
			$server_name = $with_env
		} else {
			$server_name = "www.${with_env}"
		}

		if $auth {
			$auth_user = $auth['user']
			$auth_pass = $auth['password']

			exec { "create htpasswd for ${vhost_name}":
				command => "printf \"${auth_user}:$(openssl passwd -crypt ${auth_pass})\n\" >> .htpasswd",
				creates => "${path}/.htaccess",
				path => 'usr/bin',
				require => [
					Personal::Types::Clone[$vhost_name],
					Package['openssl'],
				],
				cwd => $path,
			}
		}

		file { "${vhost_name} vhost":
			ensure => file,
			content => template('personal/nginx_vhost.erb'),
			path => "/etc/nginx/sites-available/${vhost_name}",
			mode => '755',
			owner => $username,
			group => 'nginx',
			require => [
				Package['nginx'],
				File['sites_available'],
			],
			notify => Service['nginx'],
		}

		# Symlink our vhost in sites-enabled to enable it
		file { "${vhost_name} vhost enable":
			ensure => link,
			path => "/etc/nginx/sites-enabled/${vhost_name}",
			target => "/etc/nginx/sites-available/${vhost_name}",
			mode => '755',
			owner => $username,
			group => 'nginx',
			notify => Service['nginx'],
			require => [
				File["${vhost_name} vhost"],
				File['sites_enabled'],
			],
		}

		file { "sites symlink ${vhost_name}":
			ensure => link,
			path => "/home/${username}/sites/${vhost_name}",
			target => $path,
			mode => '755',
			owner => $username,
			require => [
				File['user sites dir'],
				File["${vhost_name} vhost"],
			]
		}

		ensure_resource('file', 'user sites dir', {
			ensure => directory,
			path => "/home/${username}/sites",
			mode => '755',
			owner => $username,
		})

		ensure_resource('file', 'user vhosts dir', {
			ensure => link,
			path => "/home/${username}/nginx_config",
			target => '/etc/nginx/sites-available',
			mode => '755',
			owner => $username,
			require => File['sites_available'],
		})
	}
define personal::types::vhost (
		$vhost_name = $title,
		$path,
		$deny_hidden = true,
		$gzip = true,
		$php = false,
		$auth = undef,
	) {

		# determine what to actually call this subdomain
		if $fqdn == 'GLaDOS-local' {
			$with_env = "sbx.${vhost_name}"
			$username = 'vagrant'
		} else {
			$with_env = $vhost_name
			$username = 'isaac'
		}

		# do a regex to see if it contains more
		# than one period instead of passing param
		$is_subdomain = $vhost_name =~ /\S+\.\S+\.\S+/
		$redirect_to_www = !$is_subdomain

		# if we're a subdomain, we should do another substitution here
		if $is_subdomain {
			$server_name = $with_env
			# take out the subdomain string and period
			$parent_domain = regsubst($vhost_name, "^/S+/.", "")
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
			require => Package['nginx'],
		}

		# Symlink our vhost in sites-enabled to enable it
		file { "${vhost_name} vhost enable":
			ensure => link,
			path => "/etc/nginx/sites-enabled/${vhost_name}",
			target => "/etc/nginx/sites-available/${vhost_name}",
			notify => Service['nginx'],
			require => [
				File["${vhost_name} vhost"],
			],
		}

		file { "sites symlink ${vhost_name}":
			ensure => link,
			path => "/home/${username}/sites/${vhost_name}",
			target => $path,
			require => [
				File['user sites dir'],
				File["${vhost_name} vhost"],
			]
		}

		ensure_resource('file', 'user sites dir', {
			path => "/home/${username}/sites",
			ensure => directory,
		})

		ensure_resource('file', 'user vhosts dir', {
			ensure => link,
			path => "/home/${username}/nginx_config",
			target => '/etc/nginx/sites-available',
		})
	}
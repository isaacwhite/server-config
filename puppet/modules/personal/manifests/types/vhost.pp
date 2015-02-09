define personal::types::vhost (
		$host_param = $title,
		$subdomain_of = '',
		$subdomain = 'dev',
		$php = false,
	) {

		# allow for regular domains and subdomains.
		$is_subdomain = size($subdomain_of) > 0

		if $is_subdomain {
			$host = $subdomain_of
			$full_host = "${subdomain}.${subdomain_of}"
			$www_root = "/var/www/${host}/subdomains/${subdomain}/public_html"
			$redirect_to_www = false
		} else {
			$host = $host_param
			$full_host = $host_param
			$www_root = "/var/www/${host}/public_html"
			$redirect_to_www = true
		}

		if $fqdn == 'GLaDOS-local' {
			$with_env = "sbx.${full_host}"
		} else {
			$with_env = $full_host
		}

		if $is_subdomain {
			$aliases = [$with_env]
		} else {
			$aliases = ["www.${with_env}"]
		}


		if $php {
			$try_files = ['$uri', '$uri/', "/index.php\$is_args\$args" ]
		} else {
			$try_files = undef
		}


		nginx::resource::vhost { $full_host:
			server_name => $aliases,
			www_root => $www_root,
			try_files => $try_files,
			rewrite_non_www_to_www => $redirect_to_www,
		}


		if $php {

			nginx::resource::location { "${full_host}_php":
				ensure          => present,
				vhost           => $full_host,
				www_root        => $www_root,
				location        => '~ \.php$',
				index_files     => ['index.php', 'index.html', 'index.htm'],
				notify          => Class['nginx::service'],
				proxy           => undef,
				fastcgi         => "127.0.0.1:9000",
				fastcgi_script  => undef,
				location_cfg_append => {
					fastcgi_connect_timeout => '3m',
					fastcgi_read_timeout    => '3m',
					fastcgi_send_timeout    => '3m',
					fastcgi_split_path_info => '^(.+\.php)(/.*)$',
					fastcgi_index => 'index.php',
					fastcgi_param => ['SCRIPT_FILENAME $request_filename'],
					'include' => 'fastcgi_params',
				},
		   }

		}
	}
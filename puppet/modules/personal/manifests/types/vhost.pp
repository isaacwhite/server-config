define personal::types::vhost (
		$vhost_name = $title,
		$path,
		$php = false,
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

		if $is_subdomain {
			$aliases = [$with_env]
		} else {
			$aliases = ["www.${with_env}"]
		}

		# depending on if we will be using php or not, adjust the try paths
		if $php {
			$try_files = ['$uri', '$uri/', "/index.php\$is_args\$args" ]
		} else {
			$try_files = undef
		}

		nginx::resource::vhost { $vhost_name:
			server_name => $aliases,
			www_root => $path,
			try_files => $try_files,
			rewrite_non_www_to_www => !$is_subdomain,
		}

		if $php {

			nginx::resource::location { "${vhost_name}_php":
				ensure          => present,
				vhost           => $vhost_name,
				www_root        => $path,
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
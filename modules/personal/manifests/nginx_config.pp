class personal::nginx_config {

	include $personal::params
	include stdlib

	# make sure nginx is installed and running
	class { 'nginx': }

	create_resources(nginx_vhost, $personal::params::vhosts)

	define nginx_vhost (
		$host_param = $title,
		$subdomain_of = '',
		$subdomain = 'dev',
		$php = false,
	) {

		# allow for regular domains and subdomains.
		if size($subdomain_of) > 0 {
			$host = $subdomain_of
			$full_host = "${subdomain}.${subdomain_of}"
			$www_root = "/var/www/${host}/subdomains/${subdomain}/public_html"
		} else {
			$host = $host_param
			$full_host = $host_param
			$www_root = "/var/www/${host}/public_html"
		}

		if $fqdn == 'GLaDOS-local' {
			$with_env = "local.${full_host}"
		} else {
			$with_env = $full_host
		}

		$www_host = "www.${with_env}"
		# aliases
		$aliases = concat([$with_env], $www_host)

		if $php {
			$try_files = " /index.php\$is_args\$args"
		} else {
			$try_files = " /index.html"
		}

		nginx::resource::vhost { $full_host:
	  		server_name => $aliases,
	  		www_root => $www_root,
	  		try_files => ['$uri', '$uri/', "${try_files}"],
		}

		$backend_port = 9000

		if $php {
			nginx::resource::location { "${full_host}_php":
		     ensure          => present,
		     vhost           => $full_host,
		     www_root        => $www_root,
		     location        => '~ \.php$',
		     index_files     => ['index.php', 'index.html', 'index.htm'],
		     notify          => Class['nginx::service'],
		     proxy           => undef,
		     fastcgi         => "127.0.0.1:${backend_port}",
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
}

class personal::nginx_config {

	# lets set up nginx from scratch.
	# the nginx package is installed via personal::packages
	service { 'nginx':
	    ensure => running,
	    require => Package['nginx'],
	}

	# Disable the default nginx vhost
  	file { 'default-nginx-disable':
	    path => '/etc/nginx/sites-enabled/default',
	    ensure => absent,
	    require => Package['nginx'],
  	}
}

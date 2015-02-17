class personal::nginx_config {

	# make sure nginx is installed and running
	# class { 'nginx': }

	# we'll take care of particular vhosts later, 
	# on a site by site basis

	# lets set up nginx from scratch.
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

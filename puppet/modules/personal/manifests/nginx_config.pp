class personal::nginx_config {

	# lets set up nginx from scratch.
	# the nginx package is installed via personal::packages
	service { 'nginx':
	    ensure => running,
	    require => Package['nginx'],
	}

	# Disable the default nginx vhost
  	file { 'default-nginx-disable':
	    path => '/etc/nginx/conf.d/default.conf',
	    ensure => absent,
	    require => Package['nginx'],
  	}

  	file { 'nginx conf': 
  		path => '/etc/nginx/nginx.conf',
  		source => "puppet:///modules/personal/nginx.conf",
  		ensure => present,
  		mode => '0644',
  		require => Package['nginx'],
  		notify => Service['nginx'],
  	}

  	file { 'sites_available':
  		ensure => directory,
  		path => '/etc/nginx/sites-available',
  		mode => '755',
  		require => Package['nginx'],
  	}

  	file {'sites_enabled':
  		ensure => directory,
  		path => '/etc/nginx/sites-enabled',
  		mode => '755',
  		require => Package['nginx'],
  	}

}

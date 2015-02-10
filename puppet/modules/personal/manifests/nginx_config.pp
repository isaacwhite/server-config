class personal::nginx_config {

	# make sure nginx is installed and running
	class { 'nginx': }

	# we'll take care of particular vhosts later, 
	# on a site by site basis
}

class personal::params {
	# OHMYZSH
	$zsh_theme = 'amuse_custom'
	$box_username = 'vagrant'
	$zsh_theme_filename = "${zsh_theme}.zsh-theme"

	# NGINX CONFIG
	$isaac = 'isaacwhite.com'
	$jrw = 'joshuarobertwhite.com'
	$sh = 'solomonhoffman.com'
	$rheo = 'rheomail.com'

	$vhosts = {
		"${isaac}" => {
			php => false,
		},
		"dev.${isaac}" => {
			php => false,
			subdomain_of => $isaac,
		},
		"mytimes.${isaac}" => {
			php => true,
			subdomain_of => $isaac,
			subdomain => 'mytimes',
		},
		"scylla.${isaac}" => {
			php => true,
			subdomain_of => $isaac,
			subdomain => 'scylla',
		},
		"${jrw}" => {
			php => false,
		},
		"dev.${jrw}" => {
			php => true,
			subdomain_of => $jrw,
		},
		"${sh}" => {
			php => false,
		},
		"dev.${sh}" => {
			php => true,
			subdomain_of => $sh,
		},
		"${rheo}" => {
			php => false,
		},
		"data.${rheo}" => {
			php => true,
			subdomain_of => $rheo,
			subdomain => 'data',
		},
	}


	# MYSQL CONFIG
	$mysql_root = 'password'

	$db_path = '/var/www/dbs'

	$dbs = {
		'hoffman' => {
			path => "${db_path}/hoffman.sql",
		},
		'mytimes' => {
			path => "${db_path}/mytimes.sql",
		},
		'scylla' => {
			path => "${db_path}/scylla.sql",
		},
		'jrw' => {
			path => "${db_path}/jrw.sql",
		},
	}
}

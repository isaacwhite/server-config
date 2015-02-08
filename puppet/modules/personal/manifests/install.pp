class personal::install {

	# sets up packages for other classes
	include personal::packages
	# set timezone to EST
	include personal::timezone
	# provide zsh default shell
	include personal::zsh_config
	# firewall rules
	include personal::firewall_config
	# vhosts / server config
	include personal::nginx_config
	# php
	include personal::php_config
	# files (binary and dbs)
	include personal::files_config
	# db installs
	include personal::mysql_config

	# mysql is dependent on existing files
	Class['personal::files_config'] -> Class['personal::mysql_config']

	# make sure all repos are updated before packages everywhere.
	Yumrepo <| |> -> Package <| |>
}

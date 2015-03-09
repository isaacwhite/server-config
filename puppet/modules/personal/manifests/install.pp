class personal::install {

	# sets up packages for other classes
	include personal::config::packages
	# set timezone to EST
	include personal::config::timezone
	# provide zsh default shell
	include personal::config::zsh
	# firewall rules
	include personal::config::firewall
	# vhosts / server config
	include personal::config::nginx
	# php
	include personal::config::php
	# files (binary and dbs)
	include personal::config::files
	# db installs
	include personal::config::mysql
	# drush
	include personal::config::drush
	# kick off domain configs
	include personal::config::domains
}

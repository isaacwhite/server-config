class personal::install {

	include personal::timezone
	include personal::zsh_config
	include personal::nginx_config
	include personal::firewall_config
	include personal::php_config
	include personal::mysql_config

}

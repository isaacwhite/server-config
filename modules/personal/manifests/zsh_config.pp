class personal::zsh_config {

	include $personal::params

	# alias some params for easy access
	$username = $personal::params::box_username
	$zsh_theme = $personal::params::zsh_theme
	$zsh_filename = $personal::params::zsh_theme_filename

	# symlink to make ohmyzsh work.
	file {'/usr/bin/zsh':
		ensure => link,
		target => '/bin/zsh',
	}

	# include ohmyzsh module after symlink is setup
	->
	class{ 'ohmyzsh':}

	# install for environment user
	ohmyzsh::install{$username:
	}

	# add the custom theme after ohmyzsh is configured
	->
	file {'custom zsh theme':
		ensure => present,
		path => "/home/$username/.oh-my-zsh/themes/$zsh_filename",
		source => "puppet:///modules/personal/$zsh_filename",
	}

	# set the theme after the custom file has been added.
	->
	ohmyzsh::theme{$username:
		theme => $zsh_theme,
	}
}

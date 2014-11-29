class personal::zsh_config {

	include $personal::params

	# alias some params for easy access
	if $fqdn == 'GLaDOS-local' {
		$username = $personal::params::box_username
	} else {
		$username = 'isaac'

		user {'isaac':
			ensure => present,
			password => '$6$4wsq.4tKNDF8wxCQ$3dGv4oWoHZN.o022CgxH2W.Ho2roE3/ggMyI2mR8Bell1esYaFuoruuhsbCZxWLPzgzcnlo5kNfDTDP9hC4De1',
			managehome => true,
			shell => '/bin/zsh',
		}
	}

	$zsh_theme = $personal::params::zsh_theme
	$zsh_filename = $personal::params::zsh_theme_filename

	$user_folder = "/home/${username}/.oh-my-zsh"

	# the ohmyzsh module doesn't seem to work properly,
	# we'll do the following configs manually.

	if(!defined(Package['git'])) {
		package { 'git':
			ensure => present,
		}
	}

	if(!defined(Package['zsh'])) {
		package { 'zsh':
			ensure => present,
		}
	}

	$indicator_file = '/ohmyzsh-installed'
	exec {'install ohmyzsh':
		command => "/usr/bin/git clone https://github.com/robbyrussell/oh-my-zsh.git ${user_folder} && touch ${indicator_file}",
		require => Package['git','zsh'],
		creates => $indicator_file,
	}

	file {'custom zsh theme':
		ensure => present,
		path => "/home/$username/.oh-my-zsh/themes/$zsh_filename",
		source => "puppet:///modules/personal/$zsh_filename",
		require => Exec['install ohmyzsh'],
	}

	file {'zshrc':
		ensure => present,
		path => "/home/$username/.zshrc",
		source => "puppet:///modules/personal/.zshrc",
		require => Exec['install ohmyzsh'],
	}

}

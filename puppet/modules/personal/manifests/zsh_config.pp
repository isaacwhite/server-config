class personal::zsh_config {

	# pull private data out of hiera
	$private_data = hiera('access')
	$password = $private_data['user_password']['hash']

	# alias some params for easy access
	if $fqdn == 'GLaDOS-local' {
		$username = 'vagrant'

		user {$username:
			shell => '/bin/zsh',
			require => Package['zsh'],
		}

	} else {
		$username = 'isaac'

		user {'isaac':
			ensure => present,
			password => $password,
			managehome => true,
			shell => '/bin/zsh',
			require => Package['zsh'],
			groups => 'wheel'
		}

		# make sure users in the wheel group have sudo access
		file {'/etc/sudoers.d/01wheel':
			ensure => present,
			mode => 440,
			owner => 'root',
			group => 'root',
			content => '%wheel ALL=(ALL)  ALL',
		}
	}

	$zsh_theme = 'amuse_custom'
	$zsh_filename = "${zsh_theme}.zsh-theme"
	$user_folder = "/home/${username}/.oh-my-zsh"

	# the ohmyzsh module doesn't seem to work properly,
	# we'll do the following configs manually.

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
		path => "/home/${username}/.zshrc",
		source => "puppet:///modules/personal/.zshrc",
		require => Exec['install ohmyzsh'],
	}

}

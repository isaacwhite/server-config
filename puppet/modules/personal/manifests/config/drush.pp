class personal::config::drush {

	exec {'install drush pear channel':
		command => 'pear channel-discover pear.drush.org',
		path => '/usr/bin',
		require => Package['php-pear'],
		unless => '/usr/bin/pear list-channels | /bin/grep -q pear.drush.org',
	}

	exec {'install drush':
		command => 'pear install drush/drush',
		path => '/usr/bin',
		require => [
			Package['php-pear'],
			Exec['install drush pear channel'],
		],
		unless => '/usr/bin/test -f /usr/bin/drush',
	}

	exec {'init drush':
		command => 'drush version',
		path => '/usr/bin',
		require => Exec['install drush'],
		unless => '/usr/bin/test -d /usr/share/pear/drush/lib/Console_Table-1.1.3',
	}

}
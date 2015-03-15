class personal::config::backups {

	# pull values out of hiera
	$settings = hiera_hash('backups')
	$access = hiera_hash('access')

	# for backup template file
	$username = $personal::params::username
	$mysql_root = $access['mysql_admin']['password']
	$s3_key = $access['aws']['access']
	$s3_secret = $access['aws']['secret']
	$bucket = $access['aws']['bucket']

	# backup directories
	$home = "/home/${username}"
	$backup_dir = "${home}/backups"
	$db_dumps = "${backup_dir}/dbs"
	$files = "${backup_dir}/files"

	# script locations
	$script_location = "${backup_dir}/daily_backup.sh"
	$logfile = "${backup_dir}/daily_backup.log"

	# used for resources
	$owner = $personal::params::owner
	$group = $personal::params::group
	$required_dirs = [$backup_dir, $db_dumps, $files]

	file { $required_dirs:
		ensure => directory,
		mode => '755',
		owner => $username,
		require => User[$username],
	}

	file {"${backup_dir}/my.cnf":
		ensure => file,
		content => template('personal/mysql_access.erb'),
		mode => '700',
		owner => $username,
		require => File[$backup_dir],
	}

	$aws_config = "${home}/.aws"

	file {$aws_config:
		ensure => directory,
		owner => $username,
		mode => '700',
	}

	file {"${aws_config}/credentials":
		ensure => file,
		content => template('personal/aws_creds.erb'),
		mode => '600',
		owner => $username,
		require => File[$aws_config],
	}

	file { $script_location:
		ensure => file,
		content => template('personal/daily_backup.erb'),
		mode => '700',
		owner => $username,
		require => File[$backup_dir],
	}
	
	if $vm_environment == 'production' {

		cron { 'backup cron': 
			command => "/bin/sh ${script_location} >> ${logfile} 2>&1",
			hour => $settings['cron']['hours'],
			minute => '0',
			user => $username,
		}
		
	}

}
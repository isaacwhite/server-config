server-config
=============

A puppet config used for local development and my webserver

goals
-----
- On demand environment for local development and production
	+ Separate hiera yaml files for each
	+ simplify server deployment to two steps
		* vagrant up --provider=digital_ocean
		* change any necessary dns configs
- Synchronized resources (daily)
	+ binary files via S3
	+ database backups to S3 as well
		* local and production provisioners should pull latest resources from S3 during init process
		* will probably need to write custom puppet module for this
- Codebase tied to git repositories
	+ should be able to clone git repositories during production run
	+ useful for local environment to use symlinked code
- Integration with live reload for various sites

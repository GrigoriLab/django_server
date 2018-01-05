## Django Apache Server
Let's assume you have a django project that you would like to publish but don't have any server yet. You can simulate your real server by vagrant machine and it will barely be different from the real one.

In these case I have the repo and the website on the same server and after pushing the sourcecode it will automatically copied from master branch to the apache serve folder.

## Requirements
	ubuntu
	vagrant

## Configuring

 -  PRJ_NAME   - this should be the same name that you used for start the django app 'django-admin startapp PRJ_NAME' 
 -  DOMAIN 	   - could be any
 -  USER_NAME  - usually it will be 'vagrant', but you can run the bootstrap.sh directly on your server, so use the server's username.
 -  PRJ_PATH   - this is the path where apache serves files from.

## Running
`vagrant up`
 - then follow the log of vagrant.

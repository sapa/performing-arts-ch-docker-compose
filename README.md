

# Deployments with docker-compose

**Prerequisites:**
-   docker installed (version >= 1.9 , check with  `docker --version`)
-   docker-compose installed (version >= 1.14, check with  `docker-compose --version`)
-   outgoing HTTP/HTTPS traffic, allowing to access external docker registries (e.g. docker public or other private/corporate docker registries)


To perform any deployments or updates, you will first need to login to the metaphact's docker registry with your docker hub account, i.e. run  `docker login`. Please request your account to be added via  **[support@metaphacts.com](mailto:support@metaphacts.com)**  if you have not yet done so.

## Initial Deployment

### Mount a virtual drive in the host machine
Assuming _root_ credentials:
1.	Use `lsblk` to see where to mount a partition (**i.e.** `/vdc`) using `fdisk /dev/vdc`: (n, (default), (default), (default), w)
2.	With the partition, use `mkfs.ext4 /dev/vdc1` (`vdc1`, in this example) to create the filesystem
3.	Create a new directory `mkdir /data`
4. Use `mount /dev/vdc1 /data` to mount the filesystem
5. Edit the `/etc/fstab` file to mount it on boot
_(Note that we are following the tutorial's example name, it might differ from machine to machine)_
7.	Example of `fstab` appended line after edit:

>  /dev/vdc1 /data auto defaults 0 0

8.	Create the `/data/backup` directory (we're going to be using it for storing local backups)
 
**Note:** if you have an issue with `X11` to use `docker login`, run `sudo apt install gnupg2 pass`.

### Setup Metaphactory with blazegraph triplestore included

1.  Clone both GIT repositories: `https://github.com/sapa/performing-arts-ch-docker-compose.git` and `https://github.com/sapa/performing-arts-ch-templates.git` to the same directory
2.  Go into the  `metaphactory-docker-compose/metaphactory-blazegraph` folder
3.  The main idea idea is to maintain one subfolder for every deployment (dev, prod, other...)
4.  Go into the corresponding environment folder (`dev` folder, for example) and open the file  `.env`  e.g.  `vi .env`;
5.  If you want to, you might change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is  `dev`). The name will be used to prefix container names as well as  `vhost`  entry in the nginx proxy
6.  Run  `docker-compose up -d`. It is  **important to run the command at your-deployment directory (where the .env file is located)**, since docker-compose will pick up the  `.env`  file for parametrization
7.  Use `docker network create nginx_proxy_network` to create this network manually
8.	 Keep in mind that the _METAPHACTORY_OPTS_ differ from deployment to deployment. _Here we have already configured_ dev, prod and local.


### Setup nginx and letsencrypt

1.  Create the initial folder structure for _nginx_ config files i.e. so that one can mount the folder when creating the proxy container and place additional config files later if needed:  `mkdir -p /home/docker/config/nginx/{certs,htpasswd,vhost.d,conf.d}`  and  `touch /home/docker/config/nginx/conf.d/proxy.conf`
2.  Normally, we would copy the content of  [nginx.tmpl](https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl)  to  `/home/docker/config/nginx/nginx.tmpl`, but since we require additional forward/redirect, the script was tweaked a bit, so: copy the file at `docker-compose/nginx/nginx.tmpl` to the docker config folder instead
3.  Go into the  `cert`  folder i.e.  `cd /home/docker/config/nginx/certs`  and generate  [Diffie–Hellman](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange)  parameters using  `openssl dhparam -dsaparam -out /home/docker/config/nginx/certs/hostname.tld.dhparam.pem 4096`
	3a. The `-dsaparam`  [option instructs OpenSSL to produce "DSA-like" DH parameters](https://wiki.openssl.org/index.php/Manual:Dhparam(1)#OPTIONS), which is magnitude faster then computing the dhparam 4096 (see explanation  [on stackexchange](https://security.stackexchange.com/a/95184))
5.	Go into folder  `docker-compose/nginx`
6.  Now we are ready to create and start the proxy container. Running  `docker-compose up -d`  should result in two more containers created (check with `docker ps`): `nginx-proxy` and `nginx-proxy-gen`
7.  Verify with that the container `nginx-proxy` is running with two ports exposed:  `80, 443`
8.  From now on the  `nginx-proxy`  will listen to container changes on the docker daemon. As soon as a new docker container instance is started with a environment variable  `-e VIRTUAL_HOST=your-project-name.hostname.tld`, nginx will automatically create a vhost entry to proxy incoming HTPP(S) request on  `your-project-name.hostname.tld`  to the respective container. The environment variable is automatically set when using the metaphactory  `docker-compose.yml`  as described below. It uses the  `COMPOSE_PROJECT_NAME`  from the  `.env`  file as  `vhost`  name and as such the  `vhost`  name is equal to the prefix of metaphactory container
9. Run (at `docker-compose/nginx-letsencrypt`): `docker-compose up -d`
10. Do a `docker-compose down` and `docker-compose up -d` of all containers.

Note: if you face a proxy error, try getting first the your-project containers up, then nginx-letsencrypt and then nginx itself.

### About directories and files permissions
1.	The jetty webserver does **not** run as _root_ and does not change file ownership in volumes, so the file permissions do matter
2.	 Do a `cd /` and run `chown -R 100:0 data`. This will allow _jetty_ - within the containers - to have _rw_ privileges;
3.	To a better understanding, please refer to [https://help.metaphacts.com/resource/Help:Installation#docker-volumes](https://help.metaphacts.com/resource/Help:Installation#docker-volumes).

### Uploading existing data
1. Having access to the system, login, go to system administration (via the gear at the top right menu) > Data Import and Export
2. Click on Advanced Options and check **Keep source NamedGraphs**. Then upload the file/link that has been provided to you via _Load by HTTP/FTP/File URL_ (it **can be** a zipped version of: e.g.: `backup-2099-01-01.nq`)
	2a. Notice that you **WILL** receive a timeout in the browser, but if you do a `docker stats` you'll see a spike in CPU usage within the blazegraph container. This means it's probably working
	2b. You might check if it worked (after seeing the CPU spike normalize) if the repository contains _at least one more_ named graph and going to SPAQRL and running the exact following query:

> 	SELECT (count(*) as ?total) WHERE {   ?s ?p ?o . }
	
You shall then see far more entries.


### Setting up a webhook at Github
Here are the settings for the Github itself:

1.	At the [performing-arts-ch-templates](https://github.com/sapa/performing-arts-ch-templates) repository, go to _Settings > Webhook > Add webhook_
2.	At the _Payload URL_ put in `https://webhook-dev.hostname.tld/`; make sure the content-type is **application/json**; _pick a secret_, _Enable SSL certification_, _Just the push event_, _Check "Active"_
3.	 Now, go into the `docker-compose/metaphactory-blazegraph/your-project-container-environment-folder` (i.e: `/dev`) and, at the `.env` file, add a `WEBHOOK_SECRET` variable that will be used to sync between the repository and the project
4.	 Your `WEBHOOK_SECRET` variable should now match the secret you picked at Github
5.	The webhook container will be created based on the `Dockerfile` at `docker-compose/dev-git-webhook` at the time of creation
6.	Notice that all scripts must be with `chmod +x script.sh` otherwise the container will fail (they should already be in this particular instance).

## Setting up the backup
The backup process will be triggered by a script on the host machine. Typically you want to automate this with a cronjob.

### Setup environment variables
Inside the `metaphactory-blazegraph/dev` or `metaphactory-blazegraph/prod` folder, there is a `.env` file with the corresponding environment variables.
The _backup-container_ uses the variables configured in the `#### BACKUP CONFIGURATION ####` section.
There are already some default configuration: you may only want to change `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### Setup the cronjob
 1. Open the crontab file with `crontab -e`
	1a. Please not that this should be done with a user that has access to the docker socket. Typically you want to use `root` for that.
 2. Add the `callToBackup.sh` script, e.g.:
	```bash
	0 4 * * * /path/to/repository/backup/callToBackup.sh
	```
3. Save it and exit.

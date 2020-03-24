# Apache Guacamole Setup 

## This is to setup client-less secure access to servers for remote setup. A sample image for client access is shown below :

![Client Remote Access](images/remote_access.jpg)

All Icons in the above diagram are licensed by [Red Hat Inc](https://www.redhat.com/en) under [Creative Commons Attribution 3.0 Unported license](https://creativecommons.org/licenses/by/3.0/)

## Requirements

* Remote access to linux servers terminal (ssh) without any port forwarding etc..

* Remote access to browsers to access web servers/services exposed by servers in the Internal Network.

## Proposed Solution

* Install Apache Guacamole on a DMZ server (that allows https access) using docker images

* Configure Users (with authentication) and Groups (for Hosts) in Apache Guacamole

* Configure Connections to internal servers using ssh

* Configure X11 on the local server (on which Apach Guacamole)

* Configure VNC Connection in Apache Guacamole to localhost so that this VNC connection can be used to view browser

## Installation Steps

* Pull the required docker images

	* $ docker pull postgres
	* $ docker pull guacamole/guacd
	* $ docker pull guacamole/guacamole

* Create the desired PostGreSQL Schema Files
	* $ bash docker_scripts/create_db_schema.sh *(The original generated copy is present in this repository - it can be used)*
	* $ mkdir /opt/postgres-data *(Or any directory/folder name where you want to store persistent PostGreSQL data. Check Permissions and put selinux in permissive mode or create selinux policy)*

* Start DB Docker, Create Database and configure pg_hba.conf
	* $ bash docker_scripts/docker_start_db.sh *(To start the postgres docker instance with some environment variables and volumes)*
	* $ docker exec -it guacamole-postgres-basic /bin/bash *(To gain shell access inside the running Database Docker instance)*
	* 	root@85c12409d7a3:/# su - postgres *(To change to postgres user inside Docker Container Shell)*
	* 	postgres@85c12409d7a3:~$ createdb guacamole_db *(To create a DB to be used with Apache Guacamole)*
	* 	Logout of the Docker Container Interactive Shell *(use exit or Ctrl+D twice to exit)*
	* Stop the Docker Container and edit pg_hba.conf
	*	$ docker stop guacamole-postgres-basic
	*	# vim /opt/postgres-data/pg_hba.conf *(As root, edit the file in base host volume that stores DB Data)*
	* *(I added this line to allow all docker hosts access to the DB container without password since my docker hosts were in the network - 172.17.0.0/16)* 
	*	**host    all             all             172.17.0.0/16           trust**
	* Save and exit this file
	* Restart Docker DB --> $ docker start guacamole-postgres-basic
	
* Install psql client on localhost to connect to the Database Container and create schema in the newly created DB
	* #yum install postgresql
	* $ docker inspect guacamole-postgres-basic | grep IPAddress *(To get the IP address of the running DB Container)*
	* $ cat initdb.sql | psql -h 172.17.0.2 -U postgres -d guacamole_db -f - *(Please cd to the folder containing the sql script generated before running this command)*

* Now that the DB schema has been created and sample entries injected, start the guacd container and the guacamole container (exposing port 8080)
	* bash docker_scripts/docker_start_guacd.sh 
	* bash docker_scripts/docker_start_guacamole.sh

* Check by opening the Guacamole Login Page(http://$SERVER_IP:8080/guacamole)
	* Login as user-> guacadmin and passwdor -> guacadmin
	* Select Settings from the dropdown menu in the top-right section of the screen and Select Preferences and Change the default password
	* Also, better to create a new User from the settings menu, give it a password with permissions to create new Connections and Connection Groups *(In my case, I created a user - vbg)*
	* Logout as guacadmin

* Check the internal hosts that you will connect to with ssh from the base host
	* $ ssh <user_name>@<client_IP> *(If the ssh connection works from the guacamole server, then users logging in from remote will be able to ssh into <client_IP>)*. **You can specify password or private key for authentication in the settings for ssh connection**

* Check the internal hosts that you will connect to with VNC from the base host
	* $ vncviewer <client_IP>:<port> *(If the VNC connection works and you can open the remote server GUI, then you can use Guacamole to connect to the remote server GUI)*

* Login into guacamole with your user id and create connections using ssh and VNC. Activate those connections and work on the remote systems using your browser *(remotely open the Guacamole URL on your browser, authenticate, select a VNC or ssh connection and work on that host through the browser)*

====

## To activate VNC Server on a CentOS host

* Remember - VNC does not ask for username and password, instead it depends on the user who execeuted the VNCserver on the server. **Hence never run vncserver as root**
* On the host which you want to use VNC, ensure GNOME is installed. In my case (as should be in most cases), install VNC server on the docker host. Commands that I ran were :
	* #yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
	* #yum install tigervnc-server
	* #su - remoteadmin
	* $ vncserver *(Please specify password and read-only options when asked)*
* Allow firewall to access vncserver ports 
	* #netstat -tulpn | grep -i vnc
	* In my case the ports were **5901**
	* Allow ports 5901 (both tcp and udp), though it might just work with one protocol *(Please test if only one protocol is sufficient)*
	* #firewall-cmd --permanent --zone public --add-port=5901/tcp
	* #firewall-cmd --permanent --zone public --add-port=5901/udp
	* #firewall-cmd --reload
* Check whether the host can be connected via VNC
	* On a remote host, install vncviewer 
	* #yum install tigervnc
	* vncviewer *(Enter server host/IP and port [5901 in our example] and test)*. If vncviewer works, guacamole VNC connection will work.

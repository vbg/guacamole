# This is to setup client-less secure access to servers for remote setup. A sample image for client access is shown below :

![Client Remote Access](images/remote_access.jpg)

All Icons in the above diagram are licensed by [Red Hat Inc] (https://www.redhat.com/en) under [Creative Commons Attribution 3.0 Unported license](https://creativecommons.org/licenses/by/3.0/)

* Python Version (For now, I have used Python 3.6)\
  The URI to refer is - https://wiki.openstack.org/wiki/Python3#Current_Status  \
  Hence the base image used to build keystone is python3.6

* KEystone/Openstack Version. For now the version is Train, which I have declared as a variable in the Dockerfile

Importantly, the following dependencies must be satisfied before running this docker container :

* A running MariaDB Instance (For now I have installed only the MySQL client library - PyMySQL and hence the backend supported is MySQL). It can be further extended to LDAP and for external authentication to keystone.. Time permitting, we shall try that one day..

* Create a new database and associated user credentials in Mariadb.. As an example, the following commands can be used :

   MariaDB [none]>CREATE database new_keystone;\
   MariaDB [none]> GRANT ALL PRIVILEGES ON new_keystone.* TO 'vbg_osp'@'%' identified by 'admin';\
   MariaDB [none]> GRANT ALL PRIVILEGES ON new_keystone.* TO 'vbg_osp'@'localhost' identified by 'admin';

* Once this has been done, build your keystone image, by cloning this repo and executing a docker build:\ 
   Change Directory to the folder where you have cloned the repo and cd  to the keystone folder\
   execute the build command (as an example, on my system, I used : $docker build -t vbg-osp-keystone .)

* Once docker builds successfully, execute the docker command with the required variables.\
  As an example, I used the following command to spin up my keystone container :\
  docker run -d --name vbg-keystone  -e "DB_HOST=172.27.0.1" -e "DB_USER=vbg_osp" -e "DB_PASS=admin" -e "DB_NAME=new_keystone" -e "WEB_SERVER=testkeystone.vbg.org" -e "ADMIN_PASS=redhat" -e "REGION=RegionOne" vbg-osp-keystone


If the container runs successfully, and you can see it running in the output of the docker ps command, build the osp-client container and test the image.

Go through the following documentation to test your keystone container : https://docs.openstack.org/keystone/train/ \
Do refer specifically to the admin docs at - https://docs.openstack.org/keystone/train/admin/index.html

# Important ToDo

* This is a basic configuration for testing. For Opesntack usage a few other changes will be required in the keystone.conf file.\
  These instructions will be added in a separate project file that will glue together all of OpenStack's Components.

* This docker image is HUGE.. The size on my system is 1.73 GB. This is not desirable at all.. Eventually, once all the components of Openstack have been built, tested and linked, unnecessary build files and temporary files need to be removed to bring this image to "production size"

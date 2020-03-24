#!/bin/bash
sudo /usr/bin/docker run --name guacamole --link guacamole-guacd:guacd --link guacamole-postgres-basic:postgres -e POSTGRES_DATABASE=guacamole_db -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=redhat -d -p 8080:8080 guacamole/guacamole

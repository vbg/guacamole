#!/bin/bash
sudo /usr/bin/docker run --name guacamole-postgres-basic -e POSTGRES_PASSWORD=redhat -v /opt/postgres-data:/var/lib/postgresql/data -d postgres

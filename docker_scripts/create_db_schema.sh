#!/bin/bash
/usr/bin/docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > sql/initdb.sql

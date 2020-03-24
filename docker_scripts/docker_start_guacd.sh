#!/bin/bash
sudo /usr/bin/docker run --name guacamole-guacd -e GUACD_LOG_LEVEL=debug -d guacamole/guacd

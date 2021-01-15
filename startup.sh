#!/bin/sh
# Enter the source directory to make sure the script runs where the user expects
cd /home/site/wwwroot
export APACHE_DOCUMENT_ROOT='/home/site/wwwroot'
export APACHE_PORT=8080

apache2-foreground
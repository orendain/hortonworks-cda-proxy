#!/usr/bin/env bash

# TODO: Create separate list of TCP/UDP ports (ports expected to be accessed via non-HTTP)

httpPorts=(1080 2181 4200 4557 6080 6627 6667 7777 7788 8000 8080 8081 8088 8090 8744 8886 8888 9088 9089 9090 9091 9995 16010 19888 21000 50070 61080 61888 15500 15501 15502 15503 15504 15505 15506 15507 15508 15509 15510)

for port in ${httpPorts[@]}; do
cat << EOF >> http-hdf.conf
server {
  listen $port;
  server_name sandbox-hdf.hortonworks.com;
  location / {
    proxy_pass http://sandbox-hdf-standalone:$port;
  }
}

EOF
done

for port in ${httpPorts[@]}; do
cat << EOF >> http-hdp.conf
server {
  listen $port;
  server_name sandbox-hdp.hortonworks.com;
  location / {
    proxy_pass http://sandbox-hdp:$port;
  }
}

EOF
done

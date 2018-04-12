#!/usr/bin/env bash

# Set the value to 'true' if the sandbox will be running on the VM.
# 'false' otherwise.
hdfEnabled=true
hdpEnabled=false

# In the case of HTTP, requests pass along the hostname the user intended to
# make a request against.  For this reason, we can distinguish what sandbox
# a request was intended for based on the content of the hostname and do can
# safely route all external HTTP-bound ports to each internal container.
httpPorts=(1080 2181 4200 4557 6080 6627 6667 7777 7788 8000 8080 8081 8088 8090 8886 8888 9088 9089 9091 9995 16010 19888 21000 50070 61080 61888 15500 15501 15502 15503 15504 15505 15506 15507 15508 15509 15510)

# In the case of TCP/UDP ports, we can not filter incoming connections on
# hostname, and so must then have 1-to-1 mappings from EXTERNAL_PORTs to
# INTERNAL_PORTs.
#
# Use the following format:
# ["EXTERNAL_PORT"]="INTERNAL_PORT"
# Template: [""]=""
tcpPortsHDF=(["2223"]="22" ["8744"]="8744" ["9090"]="9090")
tcpPortsHDP=(["2222"]="22" ["15511"]="15513")



######################################################################
########### No changes should be needed beyond this point. ###########
######################################################################



# Clear conf files and then recreate necessary directories
rm -rf /sandbox/proxy/conf.d
rm -rf /sandbox/proxy/conf.stream.d
mkdir -p /sandbox/proxy/conf.d
mkdir -p /sandbox/proxy/conf.stream.d


if [ "$hdfEnabled" = true ]; then
  for port in ${httpPorts[@]}; do
    cat << EOF >> /sandbox/proxy/conf.d/http-hdf.conf
server {
  listen $port;
  server_name sandbox-hdf.hortonworks.com;
  location / {
    proxy_pass http://sandbox-hdf-standalone:$port;
  }
}
EOF
  done

  for origin in "${!tcpPortsHDF[@]}"; do
    cat << EOF >> /sandbox/proxy/conf.stream.d/tcp-hdf.conf
server {
  listen $origin;
  proxy_pass sandbox-hdf-standalone:${tcpPortsHDF[$origin]};
}
EOF
  done
fi

if [ "$hdpEnabled" = true ]; then
  for port in ${httpPorts[@]}; do
    cat << EOF >> /sandbox/proxy/conf.d/http-hdp.conf
server {
  listen $port;
  server_name sandbox-hdp.hortonworks.com;
  location / {
    proxy_pass http://sandbox-hdp:$port;
  }
}
EOF
  done

  for origin in "${!tcpPortsHDP[@]}"; do
    cat << EOF >> /sandbox/proxy/conf.stream.d/tcp-hdp.conf
server {
  listen $origin;
  proxy_pass sandbox-hdp:${tcpPortsHDP[$origin]};
}
EOF
  done
fi


# Generate the appropriate 'docker run' command by finding all ports to expose
# (found in the above lists).

cat << EOF > /sandbox/proxy/proxy-deploy.sh
#!/usr/bin/env bash
docker run --name sandbox-proxy --network=cda \\
-v /sandbox/proxy/nginx.conf:/etc/nginx/nginx.conf \\
-v /sandbox/proxy/conf.d:/etc/nginx/conf.d \\
-v /sandbox/proxy/conf.stream.d:/etc/nginx/conf.stream.d \\
EOF

for port in ${httpPorts[@]}; do
  cat << EOF >> /sandbox/proxy/proxy-deploy.sh
-p $port:$port \\
EOF
done
for port in ${!tcpPortsHDF[@]}; do
  cat << EOF >> /sandbox/proxy/proxy-deploy.sh
-p $port:$port \\
EOF
done
for port in ${!tcpPortsHDP[@]}; do
  cat << EOF >> /sandbox/proxy/proxy-deploy.sh
-p $port:$port \\
EOF
done

cat << EOF >> /sandbox/proxy/proxy-deploy.sh
-d hortonworks/sandbox-proxy:latest
EOF

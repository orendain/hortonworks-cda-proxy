FROM nginx:latest

LABEL maintainer="eorendain@hortonworks.com"

# Copy over nginx conf files
COPY http-hdf.conf /etc/nginx/conf.d
COPY http-hdp.conf /etc/nginx/conf.d

# Sourced from generate-nginx-confs.sh
EXPOSE 1080 2181 4200 4557 6080 6627 6667 7777 7788 8000 8080 8081 8088 8090 8744 8886 8888 9088 9089 9090 9091 9995 16010 19888 21000 50070 61080 61888 15500 15501 15502 15503 15504 15505 15506 15507 15508 15509 15510

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]

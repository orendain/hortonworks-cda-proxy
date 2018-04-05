# hortonworks-proxy

## To Build
```
./generate-nginx-confs.sh
docker build -t hortonworks/sandbox-proxy .
```


## To Deploy
```
docker run --name sandbox-proxy -d hortonworks/sandbox-proxy
```

## Optional: override included nginx.conf with the following:
```
docker run --name sandbox-proxy -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d hortonworks/sandbox-proxy
```

# hortonworks-sandbox-proxy

For use in the Hortonworks Sandbox, included scripts may need tweaking based on sandbox distribution and version (found in private, internal repositories).

## To Build
```
./generate-proxy-deploy-script.sh
docker build -t hortonworks/sandbox-proxy .
```


## To Deploy
```
bash /sandbox/proxy/proxy-deploy.sh
```
Note: The file above is generated when 'generate-proxy-deploy-script.sh' is run.

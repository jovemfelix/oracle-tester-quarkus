# oracle-tester-quarkus
> Example project to test a connection to Oracle, already includes driver

## To validate connection
```sh
# make GET request at /test-connection
$ curl -k https://my-host:8080/test-connection
```

## More info, here:
* [To deploy at Openshift using existing image](openshift-deployment-sample.yaml)
* [Configuration used](src/main/resources/application.properties)
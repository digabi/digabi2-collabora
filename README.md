# abitti2-collabora
Collabora Online for Abitti2

## Building 

Build the image with the following command

```
docker build -t collabora .
```

## Running

Set the environment variable HOST_NAME (host name and port) and run the following command

```
docker run --rm -it --network ktpjs_ktpjs_network --hostname collabora --env username=test --env password=test --env extra_params="--o:server_name=${HOST_NAME}" collabora
```

## Release

To release a development version of Collabora, run `dev-release.sh`. This will build and publish the Collabora image to private ECR

To release a production version of Collabora, run `release.sh`. This will prompt you for a tag to promote for a production release. The image with the corresponding tag will be transferred from the private ECR to the public ECR.

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
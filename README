This repo contains a Dockerfile which will build an image that contains Jupyter
notebooks and .NET 5.0 kernels for C# and F#.

To build the image, simply use `docker build .`.

To run the image, use 

```
docker run -p 8888:8888 --volume=$PWD/notebooks:/home/jovyan/notebooks fsharp-jupyter
```

This will start the image make it available via http.  (You should definitely 
be on a secure network to run this.)

If you need to debug a bit in the image, run the image with the 
`-e GRANT_SUDO=yes` option

```
docker run -e GRANT_SUDO=yes -p 8888:8888 --user=root --volume=$PWD/notebooks:/home/jovyan/notebooks fsharp-jupyter
```

and attach to the image with

```
docker exec -it <container name> /bin/bash
```

This repo contains a Dockerfile which will build an image that contains Jupyter
notebooks and .NET 6.0 kernels for C# and F#.

To build the image, simply use `docker build . -t fsharp-deeplearning`.

To run the image, use 

```
docker run -d --name fsharp-deeplearning -p 8888:8888 -v $PWD:/home/user/local --restart unless-stopped fsharp-deeplearning
```

This will start the image make it available via http.  (You should definitely 
be on a secure network to run this.)

If you need to debug a bit in the image, run the image with the 
`-e GRANT_SUDO=yes` option

```
docker run -d -e GRANT_SUDO=yes --name fsharp-deeplearning -p 8888:8888 -v $PWD:/home/user/local --restart unless-stopped fsharp-deeplearning
```

and attach to the image with

```
docker exec -it fsharp-deeplearning /bin/bash
```

The password for the site is by default "Deep Learning From Scratch" contained in the `jupyter_notebook_config.json` file.  You can set a new password using these [instructions](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html).  (I set up a password because I didn't want to have to know the token to be able to use my notebooks.)


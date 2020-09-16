A Dockerfiles collection
===

## firefox

Details (such as the Dockerfile) can be found [here](firefox)

You can simply build/execute it by running:


```console
docker build -t firefox .
```

```console
docker run --rm --name firefox \
           --hostname firefox -d \
           -v /var/run/dbus:/var/run/dbus \
           -v /run/user/$UID/pulse:/run/user/$UID/pulse \
           -v  /tmp/.X11-unix:/tmp/.X11-unix \
           -v /home/$USER/.pulse-cookie:/home/firefox/.pulse-cookie \
           -e DISPLAY=$DISPLAY \
           -v /home/$USER/Downloads:/home/firefox/Downloads:rw \
           -v /dev/shm:/dev/shm firefox
```

**Note:**
You can optionally mount the /home/$USER/.mozilla directory if you want to keep your
profile/extensions.

**Warn:**
You maybe want to run `xhost +local:` if a DISPLAY export error is arised by the container.


## Taskwarrior docker server

Details (such as the Dockerfile) can be found [here](taskd)

The first thing to do is build the container image or pull it from docker hub.

    docker build -t fmount/taskd:1.2.0 .

The default image generates a container that runs the server on localhost:53589
In order to expose the service, you need to modify the taskd server conf and run it
on **0.0.0.0:53589**, so the conf looks like:

    confirmation=1
    extensions=/usr/local/libexec/taskd
    ip.log=on
    log=/tmp/taskd.log
    pid.file=/tmp/taskd.pid
    queue.size=10
    request.limit=1048576
    root=/var/taskd
    server=0.0.0.0:53589
    trust=strict
    verbose=1
    client.cert=/var/taskd/client.cert.pem
    client.key=/var/taskd/client.key.pem
    server.cert=/var/taskd/server.cert.pem
    server.key=/var/taskd/server.key.pem
    server.crl=/var/taskd/server.crl.pem
    ca.cert=/var/taskd/ca.cert.pem


The image stores configuration and data in /var/taskd, which you should persist somewhere, 
so you can run it mounting your own data to the taskd server like this:

    docker run --name td -p 53589:53589 -v /home/user/taskd-srv:/var/taskd:Z fmount/taskd:1.2.0

or you can start the docker container without any volume:

    docker run --name td -p 53589:53589 fmount/taskd:1.2.0

and then copy all client conf from the /var/taskd:

    docker cp the_magical_tomato:/var/taskd/client.cert.pem
    docker cp the_magical_tomato:/var/taskd/client.key.pem
    docker cp the_magical_tomato:/var/taskd/ca.cert.pem

According to this doc, to add/import users/organizations in your taskd server, you need to attach to
the container and make some configurations as this docs suggest:

* https://taskwarrior.org/docs/taskserver/user.html
* https://taskwarrior.org/docs/taskserver/taskwarrior.html
* https://taskwarrior.org/docs/taskserver/troubleshooting-sync.html

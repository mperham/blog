+++
title = "Creating a private, commercial Docker registry"
date = 2020-03-09T09:00:00-08:00
+++

One thing I've come to respect about containers are how easy they make
packaging and running Linux infrastructure.  No more fighting the distro
for the right version of a package, a dozen builds for a dozen
distro-specific packages, etc.  Everything is encapsulated within a
single container image that runs on any modern Linux.

It hasn't escaped my notice that most of my Faktory users are using the
[Docker image](https://hub.docker.com/r/contribsys/faktory) to run Faktory which means that most of my Faktory Pro and
Enterprise customers will want a Docker image too. How do I distribute
Docker images which contain my commercial builds? **Run my own Docker
image registry!** Here's how.

## Install Docker on your Server

Docker provides a container image with their [proprietary registry
server](https://hub.docker.com/_/registry) along with [documentation on
how to use it](https://docs.docker.com/registry/deploying/). It's not
open source but it is Apache licensed so anyone can run it for any
purpose.

I wasn't too happy with this step -- I don't like adding moving parts to my production servers -- but there wasn't any other supported deployment mechanism.
I developed this set of commands to install Docker and the registry image.

```bash
apt-get install -y gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install -y docker-ce docker-ce-cli containerd.io
docker pull registry:2
```

Protip: don't copy this, what I did in January 2020 can easily change.
Follow the Linux install directions on docker.com.

```
a2enmod headers proxy proxy_http
```

Proxying the registry required me to activate these Apache modules. YMMV.

## Configure Apache Proxy

I used small portions of the [Apache recipe](https://docs.docker.com/registry/recipes/apache/) provided by Docker.
Take some time to read it carefully.
The core are these lines:

```
  ProxyPass        /v2 http://localhost:5000/v2
  ProxyPassReverse /v2 http://localhost:5000/v2
```

The registry listens on localhost:5000. Apache proxies any /v2 requests to this port.

I have an atypical usecase: I have Faktory Pro customers and Faktory Enterprise customers.
Both should be able to access the registry but the general public should not.
How can I configure Apache to authenticate users from list A or list B?
Turns out it was pretty easy with a single trick: `AuthBasicProvider` allows multiple sources.

```apache
# sites-enabled/auth.conf
<AuthnProviderAlias file fpro>
	AuthUserFile "/var/fpro.passwd"
</AuthnProviderAlias>

<AuthnProviderAlias file fent>
	AuthUserFile "/var/fent.passwd"
</AuthnProviderAlias>

# sites-enabled/registry.example.com.conf
<VirtualHost *:443>
  ServerName registry.example.com

  # ... other bits removed ...

  ProxyPass        /v2 http://localhost:5000/v2
  ProxyPassReverse /v2 http://localhost:5000/v2

  <Location /v2>
    Order deny,allow
    Allow from all
    AuthName "Registry Authentication"
    AuthType basic
    AuthBasicProvider fpro fent
    Require valid-user

    <Limit POST PUT DELETE PATCH>
      Deny from all
    </Limit>
  </Location>
</VirtualHost>
```

Note that write verbs are 100% denied. So with this one block of
configuration we:

1. limit access to fpro and fent customers
2. enforce read-only access

## Pushing New Images

If Apache limits access to read only, how do we push new images?
Use an SSH tunnel to bypass Apache!
Since the registry listens on localhost:5000, I build the image on my laptop, open an SSH tunnel to localhost:5000 on the server and push new image:

```bash
ssh -N -f -L 5000:localhost:5000 root@registry.example.com
sleep 2
docker tag example/$(NAME):$(VERSION) host.docker.internal:5000/example/$(NAME):$(VERSION)
# NB: add "host.docker.internal:5000" to insecure registries in Docker Settings
docker push host.docker.internal:5000/example/$(NAME):$(VERSION)
```

Here we are forwarding laptop port 5000 to port localhost:5000 on `registry.example.com`.
That's the Registry running on the server.

This script has a little bit of magic so let me highlight a few things.
`host.docker.internal` is a special Docker hostname which I think means "the actual host OS Docker is running on" since localhost is specific to each container.
The SSH tunnel does not shut down automatically so I have to kill it manually, email me if you know how to fix that.
You have to add `host.docker.internal` to Docker's list of insecure registries so you can push without TLS.
We don't need TLS since we are using an SSH tunnel but Docker doesn't know that.

## Customer Access

Let's wave our hands a bit: now you have an accessible registry, yay!
Assume `foobar` is a user in the fpro or fent passwd files:

```
$ docker login registry.example.com
Username: foobar
Password: abc123

$ docker pull registry.example.com/example/somename:1.5.0
...
```

If the customer stops paying, you remove them from the passwd file and they lose the ability to pull images.
That's pretty straightfoward, a nice developer experience.

## Redundancy

I run several identical servers A, B and C so that if one does down, any of the others can take over a service.
The Registry limits itself to serving static files from one directory tree (e.g. `/var/www/docker`).
Pushing an image adds files to that directory tree.
I configured that directory to be replicated across all my servers so when I push an image, all servers get a copy of the image within seconds.
If server A goes down, server B can take over as `registry.example.com` with a quick DNS swap.

## Conclusion

All this took me a few days to figure out and develop but I have been very happy with the result.
Yes I had to install Docker on my server but I've had zero problems with it so far and it takes very little resources to run.
In return, Faktory installation and deployment have become much simpler for my customers using Docker.

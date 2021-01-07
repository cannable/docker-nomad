# docker-nomad

Hashicorp Nomad in a container.

## Run-Time Configuration

Here's an example that you should tweak as needed (ex. maybe don't use bridge networking):

```
docker run -d --name a_fun_name_here cannable/nomad
```

The entrypoint for the container is nomad itself (via /usr/local/bin/nomad), so tack on any additional arguments you want. If you need to bash in there, pass --entrypoint.

### "Client Mode"

Here's a fun trick. Pop this in a shell script somewhere:

```
docker run -it --rm \
  -v .:/data \
  -e NOMAD_CAPATH=/data/nomad-ca.pem \
  -e NOMAD_CLIENT_CERT=/data/cli.pem \
  -e NOMAD_CLIENT_KEY=/data/cli-key.pem \
  -e NOMAD_ADDR=https://nomad.server:4646 \
  cannable/nomad $*
```

Or use a bash alias (which is kinda ugly but works):

```
alias nomad='docker run -it --rm -v .:/data -e NOMAD_CAPATH=/data/nomad-ca.pem -e NOMAD_CLIENT_CERT=/data/cli.pem -e NOMAD_CLIENT_KEY=/data/cli-key.pem -e NOMAD_ADDR=https://nomad.server:4646 cannable/nomad'
```

Note in both of these examples, the current directory is used to hold the certs, which you should probably change. Also, the base container intentionally doesn't do any TLS or advanced config for you because, if it were me, I'd just want the vanilla product on which to base my install.


## Build-Time Configuration

**NOMAD_VERSION**

Controls the version of Nomad to install (kinda self-explanatory). Defaults to 1.0.1.

## Volumes

There are two defined in the Dockerfile:

* /var/nomad/
* /etc/nomad.d/

## Other Stuff

I threw this together while bored one afternoon. There's almost certainly something major I missed.

# WireGuard UI


## Fork Info

- https://hub.docker.com/r/adrum/wireguard-ui

Combines these two containers into one:

- https://github.com/EmbarkStudios/wg-ui
- https://github.com/linuxserver/docker-wireguard

Almost all of the documentation at https://github.com/EmbarkStudios/wg-ui is still relevant.

```
version: "3.7"
services:
  wireguard:
    image: adrum/wireguard-ui
    container_name: wireguard-ui
    privileged: true
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - WIREGUARD_UI_LISTEN_ADDRESS=:8080
      - WIREGUARD_UI_LOG_LEVEL=debug
      - WIREGUARD_UI_DATA_DIR=/data
      - WIREGUARD_UI_WG_ENDPOINT=your-endpoint-address:51820
      - WIREGUARD_UI_CLIENT_IP_RANGE=192.168.10.0/24
      - WIREGUARD_UI_WG_DNS=1.1.1.1
      - WIREGUARD_UI_NAT=true
      - WIREGUARD_UI_NAT_DEVICE=eth0
    volumes:
      - ./data:/data
      - /lib/modules:/lib/modules
    network_mode: "host"
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```
### Docker environment variables

The following is a list of docker environment variables available with their default values.

```
WIREGUARD_UI_DATA_DIR="/var/lib/wireguard-ui"
WIREGUARD_UI_LISTEN_ADDRESS=":8080"
WIREGUARD_UI_NAT=true
WIREGUARD_UI_NAT_DEVICE="eth0"
WIREGUARD_UI_CLIENT_IP_RANGE="172.31.255.0/24"
WIREGUARD_UI_AUTH_USER_HEADER="X-Forwarded-User"
WIREGUARD_UI_MAX_NUMBER_CLIENT_CONFIG=0

WIREGUARD_UI_WG_DEVICE_NAME=wg0
WIREGUARD_UI_WG_LISTEN_PORT=51820
WIREGUARD_UI_WG_ENDPOINT="127.0.0.1:51820"
WIREGUARD_UI_WG_ALLOWED_IPS="0.0.0.0/0"
WIREGUARD_UI_WG_POST_UP="iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
WIREGUARD_UI_WG_POST_DOWN="iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE"
WIREGUARD_UI_WG_DNS=
WIREGUARD_UI_WG_KEEPALIVE=
```


## Info

[![Build Status](https://github.com/EmbarkStudios/wg-ui/workflows/Build%20&%20Release/badge.svg?branch=master)](https://github.com/EmbarkStudios/wg-ui/actions)
[![Embark](https://img.shields.io/badge/embark-open%20source-blueviolet.svg)](https://github.com/EmbarkStudios)
[![Contributor Covenant](https://img.shields.io/badge/contributor%20covenant-v1.4%20adopted-ff69b4.svg)](CODE_OF_CONDUCT.md)

A basic, self-contained management service for [WireGuard](https://wireguard.com) with a self-serve web UI.
Current stable release: [v1.1.0](https://github.com/EmbarkStudios/wg-ui/releases/tag/v1.1.0)

## Features

 * Self-serve and web based
 * QR-Code for convenient mobile client configuration
 * Optional multi-user support behind an authenticating proxy
 * Zero external dependencies - just a single binary using the wireguard kernel module
 * Binary and container deployment

![Screenshot](wireguard-ui.png)

## Running

The easiest way to run wg-ui is using the container image. To test it, run:

```docker run --rm -it --privileged --entrypoint "/wireguard-ui" -v /tmp/wireguard-ui:/data -p 8080:8080 -p 5555:5555 embarkstudios/wireguard-ui:latest --data-dir=/data --log-level=debug```

When running in production, we recommend using the latest release as opposed to `latest`.

Important to know is that you need to have WireGuard installed on the machine in order for this to work, as this is 'just' a UI to manage WireGuard configs. 

### Configuration

You can configure wg-ui using commandline flags or environment variables.
To see all available flags run:

```
docker run --rm -it embarkstudios/wireguard-ui:latest -h
./wireguard-ui -h
```

You can alternatively specify each flag through an environment variable of the form `WIREGUARD_UI_<FLAG_NAME>`, where `<FLAG_NAME>` is replaced with the flag name transformed to `CONSTANT_CASE`, e.g.

```docker run --rm -it embarkstudios/wireguard-ui:latest --log-level=debug```

and

```docker run --rm -it -e WIREGUARD_UI_LOG_LEVEL=debug embarkstudios/wireguard-ui:latest```

are the same.

## Docker images

There are two ways to run wg-ui today, you can run it with kernel module installed on your host which is the best way to do it if you want performance.  

```
docker pull embarkstudios/wireguard-ui:latest
```

If you however do not have the possibility or interest in having kernel module loaded on your host, there is now a solution for that using a docker image based on wireguard-go. Keep in mind that this runs in userspace and not in kernel module.  

```
docker pull embarkstudios/wireguard-ui:userspace
```

Both images are built for `linux/amd64`, `linux/arm64` and `linux/arm/v7`. If you would need it for any other platform you can build wg-ui binaries with help from the documentation.  


## Install without Docker

You need to have WireGuard installed on the machine running `wg-ui`.

Unless you use the userspace version with docker you're required to have WireGuard installed on your host machine.  

A few installation guides:  
[Ubuntu 20.04 LTS](https://www.cyberciti.biz/faq/ubuntu-20-04-set-up-wireguard-vpn-server/)  
[CentOS 8](https://www.cyberciti.biz/faq/centos-8-set-up-wireguard-vpn-server/)  
[Debian 10](https://www.cyberciti.biz/faq/debian-10-set-up-wireguard-vpn-server/)  

### Go installation (Debian)
Install latest version of Go from (https://golang.org/dl/)

```
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
```

### Setup environment
Bash: ~/.bash_profile  
ZSH: ~/.zshrc

```
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go
```

### Install LTS version of nodejs for frontend.

```
sudo apt-get install curl software-properties-common
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt-get install nodejs
```

### Fetch wg-ui

```
git clone https://github.com/EmbarkStudios/wg-ui.git && cd wg-ui
```

### Build binary with ui

```
make build
```

### Crosscompiling

```
make build-amd64
```

```
make build-armv5
```

```
make build-armv6
```

```
make build-armv7
```

### Build step by step

```
make ui
make assets
make build
```

## Developing

### Start frontend server
```
npm install --prefix=ui
npm run --prefix=ui dev
```

### Use frontend server when running the server

```
make build
sudo ./bin/wireguard-ui --log-level=debug --dev-ui-server http://localhost:5000
```

## Contributing

We welcome community contributions to this project.

Please read our [Contributor Guide](CONTRIBUTING.md) for more information on how to get started.

## License
Licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FEmbarkStudios%2Fwireguard-ui.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FEmbarkStudios%2Fwireguard-ui?ref=badge_large)

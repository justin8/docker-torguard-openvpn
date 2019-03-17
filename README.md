# TorGuard
TorGuard docker container

# What is TorGuard
TorGuard VPN Service encrypts your connection and provides you with an anonymous IP to protect your privacy.

# How to use this image
This image provides the configuration file for each region managed by TorGuard.

The goal is to start this container first then run other container within the TorGuard VPN via `--net=container:torguard`.


## Starting the client
```Shell
docker run --cap-add=NET_ADMIN --device=/dev/net/tun --name=torguard -d \
  --dns 209.222.18.222 --dns 209.222.18.218 \
  -e 'REGION=Australia.Sydney' \
  -e 'USERNAME=torguard_username' \
  -e 'PASSWORD=torguard_password' \
  justin8/torguard-openvpn
```

Due to the nature of the VPN client, this container must be started with some additional privileges, `--cap-add=NET_ADMIN` and `--device=/dev/net/tun` make sure that the tunnel can be created from within the container.

Starting the container in privileged mode would also achieve this, but keeping the privileges to the minimum required is preferable.

## Creating a container that uses TorGuard VPN
```Shell
docker run --rm --net=container:torguard \
    tutum/curl \
    curl -s ifconfig.co
```

The IP address returned after this execution should be different from the IP address you would get without specifying `--net=container:torguard`.

# Advanced usage

## Additional arguments for the openvpn client
Every parameter provided to the `docker run` command is directly passed as an argument to the [openvpn executable](https://openvpn.net/man.html).

This will run the openvpn client with the `--pull` option:
```Shell
docker run ... --name=torguard \
  justin8/torguard-openvpn \
    --pull
```

## Avoiding using environment variables for credentials
By default this image relies on the variables `USERNAME` and `PASSWORD` to be set in order to successfully connect to the TorGuard VPN.

It is possible to use instead a pre-existing volume/file containing the credentials.
```Shell
docker run ... --name=torguard \
  -e 'REGION=USA-NEW-YORK' \
  -v 'auth.conf:auth.conf' \
  justin8/torguard-openvpn \
    --auth-user-pass auth.conf
```

## Connection between containers behind TorGuard
Any container started with `--net=container:...` will use the same network stack as the underlying container, therefore they will share the same local IP address.

[Prior to Docker 1.9](https://docs.docker.com/engine/userguide/networking/default_network/dockerlinks/) `--link=torguard:mycontainer` was the recommended way to connect to a specific container.

[Since Docker 1.9](https://docs.docker.com/engine/userguide/networking/dockernetworks/), it is recommended to use a non default network allowing containers to address each other by name.

### Creation of a network
```Shell
docker network create torguard_network
```

This creates a network called `torguard_network` in which containers can address each other by name; the `/etc/hosts` is updated automatically for each container added to the network.

### Start the TorGuard container in the torguard_network
```Shell
docker run ... --net=torguard_network --name=torguard justin8/torguard-openvpn
```

In `torguard_network` there is now a resolvable name `torguard` that points to that newly created container.

### Create a container behind the TorGuard VPN
This step is the same as the earlier one
```Shell
# Create an HTTP service that listens on port 80
docker run ... --net=container:torguard --name=myservice myservice
```

This container is not addressable by name in `torguard_network`, but given that the network stack used by `myservice` is the same as the `torguard` container, they have the same IP address and the service running in this container will be accessible at `http://torguard:80`.

### Create a container that access the service
```Shell
docker run ... --net=torguard_network tutum/curl curl -s http://torguard/
```

The container is started within the same network as `torguard` but is not behind the VPN.
It can access services started behind the VPN container such as the HTTP service provided by `myservice`.


### Available regions

For the Environment variable REGION (`-e 'REGION=XXX'`)you may use one of the following values:
```
Brazil
Bulgaria
Canada.Toronto
Canada.Vancouver
Chile
Costa Rica
Czech
Denmark
Egypt
Finland
France
Germany
Greece
Hong.Kong
Hungary
Iceland
India
Ireland
Isle.of.Man
Israel
Italy
Japan
Latvia
Luxembourg
Malaysia
Mexico
Moldova
Netherlands
New.Zealand
Norway
Poland
Portugal
Romania
Russia.Moscow
Russia.St.Petersburg
Saudi.Arabia
Singapore
South.Africa
South.Korea
Spain
Sweden
Switzerland
Taiwan
Thailand
Tunisia
Turkey
UK.London
USA-ATLANTA
USA-CHICAGO
USA-DALLAS
USA-LA
USA-LAS-VEGAS
USA-MIAMI
USA-NEW-JERSEY
USA-NEW-YORK
USA-SAN-FRANCISCO
USA-SEATTLE
Vietnam
Australia.Melbourne
Australia.Sydney
Austria
Belgium
```
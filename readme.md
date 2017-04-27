# build environment toolbox

- nodejs
- golang
- python
- fission

and `ssh`-server to connect to

## build
```
docker build -t willies/sshd .
```

## run
```
docker run --rm -it --name sshd -p 2022:22 willies/sshd
```

## install
edit `chart/values.yaml` or leave default
```
helm install --name sshd chart/
```

## connect
username is `user`, password printed in `docker logs`
```
ssh user@host
```
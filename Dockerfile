FROM registry.fedoraproject.org/fedora:25

RUN curl http://fission.io/linux/fission > fission \
    && chmod +x fission \
    && mv fission /usr/local/bin/

RUN dnf -y install vim wget git tmux python \ 
    openssh-server passwd tree procps-ng xz \ 
    gcc unzip tar \
    && dnf clean all

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]


RUN groupadd user && useradd -g user user
WORKDIR /home/user

## tmux
COPY tmux.conf .tmux.conf
RUN chown user:user .tmux.conf

## bash-it
RUN su - user -c "git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it" \
    && su - user -c "~/.bash_it/install.sh --silent" \
    && sed -i s/bobby/powerline-plain/ .bashrc

## golang
ENV GOLANG_VER=1.8.1
RUN wget -qO- https://storage.googleapis.com/golang/go${GOLANG_VER}.linux-amd64.tar.gz | tar xz -C /usr/local \
    && echo PATH=\$PATH:/usr/local/go/bin >> .bashrc \
    && echo export GOPATH=/home/user/go >> .bashrc \
    && mkdir -p go/{bin,src,pkg} && chown -R user:user go

## glide
ENV GLIDE_VER=v0.12.3
RUN wget -qO- https://github.com/Masterminds/glide/releases/download/${GLIDE_VER}/glide-${GLIDE_VER}-linux-amd64.tar.gz | tar xz -C /tmp \
    && mv /tmp/linux-amd64/glide /usr/bin \
    && chmod 755 /usr/bin/glide \
    && rm -rf /tmp/linux-amd64

## nodejs
ENV NODE_VER=v7.9.0
RUN wget -qO- https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-linux-x64.tar.xz | tar xJ -C /usr/local/ \
    && ln -s /usr/local/node-${NODE_VER}-linux-x64/ /usr/local/node \
    && echo PATH=\$PATH:/usr/local/node/bin >> .bashrc

## kubectl
ENV KUBE_VER=v1.6.2
RUN curl -O https://storage.googleapis.com/kubernetes-release/release/${KUBE_VER}/bin/linux/amd64/kubectl \
    && chmod 755 kubectl \
    && mv kubectl /usr/bin/kubectl

## kubeless
ENV KUBELESS_VER=0.0.11
RUN curl -O https://github.com/bitnami/kubeless/releases/download/${KUBELESS_VER}/kubeless_linux-amd64.zip \
    && unzip kubeless_linux-amd64.zip \
    && rm kubeless_linux-amd64.zip \
    && mv kubeless_linux-amd64/kubeless /usr/bin/kubeless \
    && rm -r kubeless_linux-amd64

## pubkeys
COPY authorized_keys .ssh/authorized_keys 
RUN chown -R user:user .ssh && chmod -R 700 .ssh \
    && echo export FISSION_URL=http://controller.fission >> .bashrc \
    && echo export FISSION_ROUTER=http://router.fission >> .bashrc

## add IDEs here

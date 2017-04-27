FROM docker.io/fedora

RUN curl http://fission.io/linux/fission > fission \
    && chmod +x fission \
    && mv fission /usr/local/bin/

RUN dnf -y install vim wget git tmux python nodejs \ 
    openssh-server passwd tree procps-ng \
    && dnf clean all

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
RUN wget -qO- https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz | tar xvz -C /usr/local \
    && echo PATH=$PATH:/usr/local/go/bin >> .bashrc

## pubkeys
COPY authorized_keys .ssh/authorized_keys 
RUN chown -R user:user .ssh && chmod 700 .ssh \
    && echo FISSION_URL=http://controller.fission >> .bashrc \
    && echo FISSION_ROUTER=http://router.fission >> .bashrc



## add IDEs here

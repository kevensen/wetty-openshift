FROM fedora
LABEL maintainer="kdevensen@gmail.com"
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    HOME=/opt/workspace
RUN dnf install -y --setopt=tsflags=nodocs \
		make \
    		nmap-ncat \
    		npm \
    		gcc-c++ \
		git \
        	origin-clients \
		openssl \
		unzip \
		java-1.8.0-openjdk-devel \
		maven \
        	openssh-server && \
    dnf clean all && \
    rm -rf /var/cache/yum/*

COPY workshop-profile.sh /etc/profile.d/
RUN chmod a+r /etc/profile.d/workshop-profile.sh

RUN mkdir /home/default && \
    useradd -u 2000 default && \
    echo "default:${WETTY_PASSWORD:-wetty}" | chpasswd && \
    chown default:default /home/default

RUN /usr/bin/ssh-keygen -A -N '' && \
    chmod -R a+r /etc/ssh/* && \
    /usr/sbin/setcap 'cap_net_bind_service=+ep' /usr/sbin/sshd

EXPOSE 22
WORKDIR /home/default
USER default

CMD ["/usr/sbin/sshd", "-D", "-p", "22", "-E", "/home/default/ssh.log"]

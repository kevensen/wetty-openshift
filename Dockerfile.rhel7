FROM rhel
LABEL maintainer="kdevensen@gmail.com"
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    HOME=/opt/workspace
RUN yum install -y --setopt=tsflags=nodocs --disablerepo='*' --enablerepo='rhel-7-server-rpms' --enablerepo='rhel-7-server-ose-3.7-rpms'\
		make \
    	nmap-ncat \
    	npm \
    	gcc-c++ \
		git \
        atomic-openshift-clients \
		openssl \
		unzip \
		java-1.8.0-openjdk-devel \
        openssh-server && \
    yum clean all && \
    rm -rf /var/cache/yum/*
ADD http://mirrors.gigenet.com/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.zip /root/apache-maven-3.5.2-bin.zip
RUN cd /root && \
    unzip /root/apache-maven-3.5.2-bin.zip && \
    mv apache-maven-3.5.2 /usr/bin/

COPY workshop-profile.sh /etc/profile.d/
RUN chmod a+r /etc/profile.d/workshop-profile.sh

RUN mkdir /home/default && \
    useradd -u 2000 default && \
    echo ${WETTY_PASSWORD} | passwd default --stdin && \
    chown default:default /home/default

RUN /usr/bin/ssh-keygen -A -N '' && \
    chmod -R a+r /etc/ssh/* && \
    rm /run/nologin && \
    /usr/sbin/setcap 'cap_net_bind_service=+ep' /usr/sbin/sshd

EXPOSE 22
WORKDIR /home/default
USER default

CMD ["/usr/sbin/sshd", "-D", "-p", "22", "-E", "/home/default/ssh.log"]
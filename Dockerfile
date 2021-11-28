FROM  docker.io/library/centos:centos7.9.2009
LABEL author=caorong

## yes | cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
RUN yes | cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
RUN echo "root:root" | chpasswd

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
         -e 's|^#baseurl=http://mirror.centos.org/centos|baseurl=https://mirrors.ustc.edu.cn/centos|g' \
         -i.bak \
         /etc/yum.repos.d/CentOS-Base.repo && yum makecache && yum install -y ca-certificates wget tar glibc-static nc unzip net-tools.x86_64 &&\
         ( /usr/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) &&\
         yum -y reinstall glibc-common &&\
         /usr/bin/localedef -c -f UTF-8 -i zh_CN zh_CN.UFT-8 &&\
         echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf &&\
         source /etc/locale.conf &&\
         sed -i '/^hosts.*/d' /etc/nsswitch.conf &&\
         echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf &&\
         yum groupinstall -y "Development Tools" &&\
         mkdir -p /package ; chmod 1755 /package && cd /tmp; wget http://smarden.org/runit/runit-2.1.2.tar.gz && tar xvzf runit-2.1.2.tar.gz --strip-components=1 && rm runit-2.1.2.tar.gz && cd runit-2.1.2 && package/install && yes | cp /tmp/runit/command/* /sbin/ &&\
	     yum clean all && yum groupremove -y "Development Tools" && rm -rf /tmp/* && rm -rf /var/cache/yum


COPY start_runit /sbin/start_runit

RUN mkdir /etc/container_environment && chmod a+x /sbin/start_runit && mkdir /etc/service && mkdir /etc/runit_init.d

CMD ["/sbin/start_runit"]


RUN chmod 700 /sbin &&\
    chmod 700 /usr/sbin &&\
    chmod 700 /usr/local/bin &&\
    chmod 700 /srv &&\
    chmod 700 /var/log &&\
    mkdir -p /logs &&\
    chmod 700 /logs &&\
    chmod 700 /etc/service


ENV LANG=zh_CN.UFT-8
ENV LC_ALL=zh_CN.UFT-8

ENV TMOUT=3600
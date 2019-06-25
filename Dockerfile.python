FROM jenkinsxio/jenkins-filerunner:0.1.49

RUN apt-get update && apt-get -y upgrade
#RUN yum install -y python36u python36u-libs python36u-devel python36u-pip

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

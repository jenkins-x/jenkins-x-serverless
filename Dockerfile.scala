FROM jenkinsxio/jenkins-filerunner:0.1.49

ENV SCALA_VERSION 2.12.5
ENV SBT_VERSION 1.1.2

RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

RUN curl -Lf -o sbt.deb http://dl.bintray.com/sbt/debian/sbt-${SBT_VERSION}.deb && \
    dpkg -i sbt.deb && \
    apt-get update && \
    apt-get install -y sbt

RUN sbt sbtVersion

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

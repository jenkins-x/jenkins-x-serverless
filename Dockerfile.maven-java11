FROM jenkinsxio/jenkins-filerunner:0.1.49

RUN curl https://download.java.net/java/ga/jdk11/openjdk-11_linux-x64_bin.tar.gz | tar -xz
RUN mv /home/jenkins/jdk-11 /usr/java
RUN rm /usr/bin/java
RUN ln -sf /usr/java/bin/* /usr/bin/
ENV JAVA_HOME /usr/java

# Maven
ENV MAVEN_VERSION 3.5.3
RUN curl -Lf http://central.maven.org/maven2/org/apache/maven/apache-maven/$MAVEN_VERSION/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -C /opt -xzv
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

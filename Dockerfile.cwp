FROM jenkinsxio/jenkins-filerunner:0.1.49

# Maven
ENV MAVEN_VERSION 3.5.3
RUN curl -Lf http://central.maven.org/maven2/org/apache/maven/apache-maven/$MAVEN_VERSION/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -C /opt -xzv
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

RUN mkdir -p /opt/cwp
ENV CWP_VERSION 1.5
RUN curl -o /opt/cwp/custom-war-packager.jar -Lf http://repo.jenkins-ci.org/releases/io/jenkins/tools/custom-war-packager/custom-war-packager-cli/$CWP_VERSION/custom-war-packager-cli-$CWP_VERSION-jar-with-dependencies.jar

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

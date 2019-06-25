FROM jenkinsxio/jenkins-filerunner:0.1.49

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
	apt-get install -y nodejs chromedriver chromium xvfb

RUN npm i -g watch-cli vsce typescript

ENV YARN_VERSION 1.3.2
RUN curl -Lf -o /tmp/yarn.tgz https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz && \	
	tar xf /tmp/yarn.tgz && \
	mv yarn-v${YARN_VERSION} /opt/yarn && \
	ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

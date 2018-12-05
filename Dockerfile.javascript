FROM jenkinsxio/jenkins-base:0.1.124

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
	apt-get install -y nodejs build-essential make bzip2 chromedriver chromium xvfb

RUN npm i -g watch-cli vsce typescript

ENV YARN_VERSION 1.3.2
RUN curl -Lf -o /tmp/yarn.tgz https://github.com/yarnpkg/yarn/releases/download/v${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz && \	
	tar xf /tmp/yarn.tgz && \
	mv yarn-v${YARN_VERSION} /opt/yarn && \
	ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn

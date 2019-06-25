FROM jenkinsxio/jenkins-filerunner:0.1.49

RUN wget https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init && \
  chmod +x rustup-init &&\
  ./rustup-init -y &&\
  rm -rf rustup-init

ENV PATH=$PATH:/root/.cargo/bin
RUN rustup override set nightly

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

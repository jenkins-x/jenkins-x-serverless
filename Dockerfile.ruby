FROM jenkinsxio/jenkins-base:256.0.110

RUN apt-get install -y bison libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev libxml2-dev libxslt-dev
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc 
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN /bin/bash -c -l "rbenv install 2.5.3"
RUN /bin/bash -c -l "rbenv global 2.5.3"
RUN /bin/bash -c -l "gem install bundler"

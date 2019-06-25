FROM jenkinsxio/jenkins-filerunner:0.1.49

ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.6

ARG GRADLE_DOWNLOAD_SHA256=98bd5fd2b30e070517e03c51cbb32beee3e2ee1a84003a5a5d748996d4b1b915
RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mkdir -p /opt \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

ENV ANDROID_VERSION 4333796
ENV ANDROID_HOME /opt/android-sdk-linux
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_VERSION}.zip && \
  unzip sdk-tools-linux-${ANDROID_VERSION}.zip -d android-sdk-linux && mv android-sdk-linux /opt/
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools"
RUN yes | sdkmanager \
    "platforms;android-28" \
    "build-tools;28.0.0"
	
#	&& echo "Adding gradle user and group" \
#	&& addgroup -S -g 1000 gradle \
#	&& adduser -D -S -G gradle -u 1000 -s /bin/ash gradle \
#	&& mkdir /home/gradle/.gradle \
#	&& chown -R gradle:gradle /home/gradle \
#	\
#	&& echo "Symlinking root Gradle cache to gradle Gradle cache" \
#	&& ln -s /home/gradle/.gradle /root/.gradle

# Create Gradle volume
#USER gradle
#VOLUME "/home/gradle/.gradle"
#WORKDIR /home/gradle

#RUN set -o errexit -o nounset \
#	&& echo "Testing Gradle installation" \
#	&& gradle --version

# jx
ENV JX_VERSION 2.0.329
RUN curl -Lf https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

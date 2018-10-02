FROM jenkins/jenkins:2.121.3
USER root
ADD target/jenkinsfile-runner-256.0-test.war /usr/share/jenkins/jenkins.war
RUN mkdir /app && unzip /usr/share/jenkins/jenkins.war -d /app/jenkins
COPY jenkinsfileRunner /app
RUN chmod +x /app/bin/jenkinsfile-runner && mkdir -p /usr/share/jenkins/ref/plugins
COPY plugins /usr/share/jenkins/ref/plugins

ENTRYPOINT ["/app/bin/jenkinsfile-runner", \
            "-w", "/app/jenkins",\
            "-p", "/usr/share/jenkins/ref/plugins",\
            "-f", "/workspace/Jenkinsfile"]

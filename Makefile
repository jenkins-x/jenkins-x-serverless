VERSION := 0.1.0-SNAPSHOT
CWP_VERSION = 1.3
JENKINSFILE_RUNNER_TAG ?= jx-jenkinsfile-runner/dev

# Just a Makefile for manual testing
.PHONY: all buildInDocker test test-k8s

all: clean buildLocally

clean:
	rm -rf tmp

.build/cwp-cli-${CWP_VERSION}.jar:
	rm -rf .build
	mkdir -p .build
	wget -O .build/cwp-cli-${CWP_VERSION}.jar https://repo.jenkins-ci.org/releases/io/jenkins/tools/custom-war-packager/custom-war-packager-cli/${CWP_VERSION}/custom-war-packager-cli-${CWP_VERSION}-jar-with-dependencies.jar

buildLocally: .build/cwp-cli-${CWP_VERSION}.jar
	java -jar .build/cwp-cli-${CWP_VERSION}.jar \
	     -tmpDir $(shell pwd)/out/tmp \
	     -configPath packager-config.yml -version ${VERSION}
	docker build -t ${JENKINSFILE_RUNNER_TAG} -f $(shell pwd)/out/tmp/output/Dockerfile $(shell pwd)/out/tmp/output/

# TODO: -v maven-repo:/root/.m2
buildInDocker:
	docker run \
	    -v $(shell pwd)/packager-config.yml:/app/packager-config.yml \
	    -v $(shell pwd)/casc.yml:/app/casc.yml \
	    -v $(shell pwd)/out:/app/out \
	    jenkins/custom-war-packager:${CWP_VERSION} \
	    -configPath /app/packager-config.yml -tmpDir /app/out/tmp -version ${VERSION}
	docker build -t ${JENKINSFILE_RUNNER_TAG} -f $(shell pwd)/out/tmp/output/Dockerfile $(shell pwd)/out/tmp/output/

test:
	docker run --rm -v $(shell pwd)/tests/Jenkinsfile-helloworld:/workspace/Jenkinsfile ${JENKINSFILE_RUNNER_TAG}

test-k8s:
	docker run --rm -v $(shell pwd)/Jenkinsfile-test:/workspace/Jenkinsfile ${JENKINSFILE_RUNNER_TAG}

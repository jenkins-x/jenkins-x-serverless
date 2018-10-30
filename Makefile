VERSION := 0.1.0-SNAPSHOT
#TODO: Actually needs 1.2, not compatible with 1.3 w/o https://github.com/jenkins-x/jenkins-x-serverless/pull/38
CWP_VERSION = latest
JENKINSFILE_RUNNER_TAG ?= jx-jenkinsfile-runner/dev

# Just a Makefile for manual testing
.PHONY: all test test-k8s

all: clean build

clean:
	rm -rf tmp

# TODO: -v maven-repo:/root/.m2
build:
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

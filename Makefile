VERSION := 0.1.0-SNAPSHOT
#TODO: needs 1.2
CWP_VERSION = latest
JENKINSFILE_RUNNER_TAG ?= jx-jenkinsfile-runner/dev

# Just a Makefile for manual testing
.PHONY: all test test-k8s

all: clean build

clean:
	rm -rf tmp

build:
	docker run \
	    -v $(shell pwd)/packager-config.yml:/app/packager-config.yml \
	    -v $(shell pwd)/casc.yml:/app/casc.yml \
	    -v $(shell pwd)/out:/app/out \
	    -v maven-repo:/root/.m2 \
	    jenkins/custom-war-packager:${CWP_VERSION} \
	    -configPath /app/packager-config.yml -tmpDir /app/out/tmp -version ${VERSION}
	docker build -t ${JENKINSFILE_RUNNER_TAG} -f $(shell pwd)/out/tmp/output/Dockerfile $(shell pwd)/out/tmp/output/

test:
	docker run --rm -v $(shell pwd)/tests/Jenkinsfile-helloworld:/workspace/Jenkinsfile ${JENKINSFILE_RUNNER_TAG}

test-k8s:
	docker run --rm -v $(shell pwd)/Jenkinsfile-test:/workspace/Jenkinsfile ${JENKINSFILE_RUNNER_TAG}

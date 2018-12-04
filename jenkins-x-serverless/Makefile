CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := serverless
OS := $(shell uname)
VERSION := $(shell cat ./VERSION)

init: 
	helm init --client-only

setup: init
	helm repo add jenkins-x http://chartmuseum.jenkins-x.io 	

build: clean setup
	helm dependency build
	helm lint

install: clean build
	helm upgrade ${NAME} . --install

upgrade: clean build
	helm upgrade ${NAME} . --install

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz
	rm -rf requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" Chart.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml
else
	exit -1
endif
	helm package .
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz

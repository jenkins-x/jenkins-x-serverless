# Just a Makefile for manual testing
.PHONY: all

all: clean build

clean:
	rm -rf tmp

build:
	java \
		-jar /opt/cwp/custom-war-packager.jar \
	    -configPath packager-config.yml -version ${VERSION}

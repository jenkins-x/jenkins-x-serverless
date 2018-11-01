VERSION := 0.1.0-SNAPSHOT

# Just a Makefile for manual testing
.PHONY: all

all: clean build

clean:
	rm -rf tmp

build:
	java \
		-jar /opt/cwp/custom-war-packager.jar \
	    -configPath packager-config.yml

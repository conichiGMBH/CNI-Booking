LOCAL_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
EXAMPLE_PATH = "$(shell pwd)/Example"

RED=`tput setaf 1`
RESET=`tput sgr0`

.PHONY: bootstrap

all: bootstrap

### CI

ci: bundler cocoapods submodules
	bundle exec fastlane scan
	bundle exec danger

### General

bootstrap: bundler cocoapods submodules example_cocoapods
	ruby config/conichi/setup.rb

### Bundle

bundler:
	bundle install

### Submodule

submodules:
	git submodule init
	git submodule update --remote

### Cocoapods

cocoapods:
	bundle exec pod repo update
	bundle exec pod install

example_cocoapods:
	cd $(EXAMPLE_PATH); bundle exec pod install; cd ..	

local_lint:
	bundle exec pod lib lint --allow-warnings --sources=https://github.com/conichiGMBH/ios-specs,master --no-clean --verbose

### Useful commands

release: bundler cocoapods
	bundle exec fastlane scan
	bundle exec fastlane ios release

changelog:
	open CHANGELOG.yml

open:
	open CNI-Itineraries.xcworkspace

### Git commands

pull:
	git pull origin $(LOCAL_BRANCH)

pr:
	if [ "$(LOCAL_BRANCH)" == "develop" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not PRing${RESET}"; elif [ "$(LOCAL_BRANCH)" == "master" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not PRing ${RESET}"; else git push origin "$(LOCAL_BRANCH):$(BRANCH)"; open "https://github.com/conichiGMBH/CNI-Booking/compare/develop...$(BRANCH)"; fi

push:
	if [ "$(LOCAL_BRANCH)" == "develop" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not pushing${RESET}"; elif [ "$(LOCAL_BRANCH)" == "master" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not pushing${RESET}"; else git push origin $(LOCAL_BRANCH):$(BRANCH); fi

fpush:
	if [ "$(LOCAL_BRANCH)" == "develop" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not pushing${RESET}"; elif [ "$(LOCAL_BRANCH)" == "master" ]; then echo "${RED}In "$(LOCAL_BRANCH)", not pushing${RESET}"; else git push origin $(LOCAL_BRANCH):$(BRANCH) --force; fi

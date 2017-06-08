REPO ?= xml_splitter
TAG  ?= $(shell git rev-parse --short HEAD)
USED_TAG := $(TAG)
define images
    docker images $(REPO)
endef
define image_ids
    $(shell docker images -q $(REPO))
endef

all: build

build: Dockerfile
		docker build --rm -t $(REPO):$(USED_TAG) .
		-docker rmi $(REPO):latest
		docker tag $(REPO):$(USED_TAG) $(REPO):latest
push:
		docker push $(REPO):$(USED_TAG)
		docker push $(REPO):latest
clean:
		docker rmi -f $(call image_ids)
list:
	$(call images)

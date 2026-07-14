PROFILE ?= development

.PHONY: build
build:
	python3 -m build --profile $(PROFILE)

.PHONY: build-dev
build-dev:
	python3 -m build --profile development

.PHONY: build-release
build-release:
	python3 -m build --profile release
PROFILE ?= development

.PHONY: build
build:
	python3 -m build --profile $(PROFILE)

.PHONY: build-dev
build-dev:
	python3 -m build --profile development

.PHONY: build-release
build-release:
	python3 -m build --profile release
PROFILE ?= development

.PHONY: build
build:
	python3 -m build --profile $(PROFILE)

.PHONY: build-dev
build-dev:
	python3 -m build --profile development

.PHONY: build-release
build-release:
	python3 -m build --profile release

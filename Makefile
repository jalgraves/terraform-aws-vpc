SHELL := /bin/bash

export SELF ?= $(MAKE)

upgrade ?= false

.SHELLFLAGS += -e
.ONESHELL: plan test/apply

## Format Terraform code
fmt:
	terraform fmt --recursive

## Run terraform init in examples/complete directory
init:
	cd examples/complete && \
		terraform init -upgrade=$(upgrade)

## Run a test plan in examples/complete directory
plan:
	cd examples/complete && \
		terraform init && \
		aws-vault exec development:dev -- terraform plan

.PHONY: test

## Runs terraform init and plan
test:
	cd test/src && \
		go mod download && \
		go test -v -timeout 60m -run TestExamplesComplete

## Clean up tfstate files in examples/complete
test/clean:
	rm -rf examples/complete/*.tfstate* || true
	rm -rf examples/complete/secrets || true
	rm -rf examples/complete/.terraform || true

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' Makefile | sort -u
	@printf "\n\n"

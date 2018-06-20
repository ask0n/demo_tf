.PHONY: help
SHELL:=/bin/bash

#aws_profile:=default
#export AWS_ACCESS_KEY_ID=$(shell sed -nE -e"0,/\[${aws_profile}\]/d" -e's/aws_access_key_id[[:space:]=]*(.*)$$/\1/p' ~/.aws/credentials | head -1)
#export AWS_SECRET_ACCESS_KEY=$(shell sed -nE -e"0,/\[${aws_profile}\]/d" -e's/aws_secret_access_key[[:space:]=]*(.*)$$/\1/p' ~/.aws/credentials | head -1)

local_var:=$$HOME/.terraformrc

GREEN:='\033[0;32m'
WHITE:='\033[0;37m'
ENV_PATH:='../../../environments/'
TL_PATH:='../../../'

ifndef ENVIRONMENT
	ENVIRONMENT := $(shell basename $(dir $(abspath $(dir $$PWD))))-$(notdir $(shell pwd))
endif

ifndef TF_VAR_region
        TF_VAR_region := "eu-central-1"
endif

ifeq ("$(wildcard .backend)","")
 ifndef TF_VAR_backend
  TF_VAR_backend := "$(TL_PATH)/backends/demo"
 endif
else
 TF_VAR_backend := ".backend"
endif

ifeq ("$(wildcard $(localvar))","")
$(shell touch ${local_var})
endif

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: check-version ## Initializes the terraform remote state backend and pulls the correct environments state.
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
	@echo -e $(GREEN)"Using ENVIRONMENT=$(ENVIRONMENT) Backend=$(TF_VAR_backend) (branch $(shell git rev-parse --abbrev-ref HEAD))"$(WHITE)
	@rm -rf .terraform/*.tf*
	@terraform init\
		-backend=true \
		-backend-config="$(TF_VAR_backend)" \
		-backend-config="region=$(TF_VAR_region)" \
		-backend-config="profile=$(TF_VAR_aws_profile)" \
		-backend-config="key=$(ENVIRONMENT).tfstate"

reinit: check-version ##Rewrite remote state on s3 from local copy
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
	@terraform init \
	        -backend=true \
		-backend-config="../backends/$(TF_VAR_backend)" \
		-backend-config="region=$(TF_VAR_region)" \
		-backend-config="profile=$(TF_VAR_aws_profile)" \
		-backend-config="key=$(ENVIRONMENT).tfstate"
	@rm -rf .terraform/*.tf*
	@$(MAKE) init

update: ## Gets any module updates
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
	@echo -e $(GREEN)"Using ENVIRONMENT=$(ENVIRONMENT) Backend=$(TF_VAR_backend) (branch $(shell git rev-parse --abbrev-ref HEAD))"$(WHITE)
	@terraform get -update=true &>/dev/null

plan: update ## Runs a plan. Note that in Terraform < 0.7.0 this can create state entries.
	@terraform plan -input=false -refresh=true -module-depth=-1 -var-file=${local_var} -var-file=$(ENV_PATH)/$(ENVIRONMENT).tfvars

plan-destroy: update ## Shows what a destroy would do.
	@terraform plan -input=false -refresh=true -module-depth=-1 -destroy -var-file=${local_var} -var-file=$(ENV_PATH)/$(ENVIRONMENT).tfvars

plan-save: update ## Saves plan to file for current environment
	@[[ -d $(TL_PATH)/plans ]] || mkdir $(TL_PATH)/plans
	@terraform plan -input=false -refresh=true -module-depth=-1 -var-file=${local_var} -var-file=$(ENV_PATH)/$(ENVIRONMENT).tfvars -out=$(TL_PATH)/plans/$(ENVIRONMENT)-`date +%Y%m%d`-$$(git rev-parse HEAD).tfplan

show: ## Shows a module
	@terraform show -module-depth=-1

graph: ## Runs the terraform grapher
	@rm -f graph.png
	@terraform graph -draw-cycles -module-depth=-1 | dot -Tpng > graph.png
	@open graph.png

apply: git-check plan-save ## Applies a new state.
	@if [ ! -f $(TL_PATH)/plans/$(ENVIRONMENT)-`date +%Y%m%d`-$$(git rev-parse HEAD).tfplan ]; then \
		echo "No Changes to apply !! Your plan is converged now!"; \
		exit 127; \
	fi
	@terraform apply $(TL_PATH)/plans/$(ENVIRONMENT)-`date +%Y%m%d`-$$(git rev-parse HEAD).tfplan \
	&& rm -v $(TL_PATH)/plans/$(ENVIRONMENT)-`date +%Y%m%d`-$$(git rev-parse HEAD).tfplan;

force-apply: init update ## Applies a new state without checks.
	@terraform apply -input=true -refresh=true -var-file=${local_var} -var-file=$(ENV_PATH)/$(ENVIRONMENT).tfvars

output: update ## Show outputs of a module or the entire state.
	@if [ -z $(MODULE) ]; then terraform output ; else terraform output -module=$(MODULE) ; fi

destroy: init update ## Destroys targets
	@terraform destroy -var-file=${local_var} -var-file=$(ENV_PATH)/$(ENVIRONMENT).tfvars

#env: ## Apply env variables for AWS from ~/.aws/credentials
#	@echo export AWS_ACCESS_KEY_ID=$(shell sed -nE -e"0,/\[${aws_profile}\]/d" -e's/aws_access_key_id[[:space:]=]*(.*)$$/\1/p' ~/.aws/credentials | head -1)\;
#	@echo export AWS_SECRET_ACCESS_KEY=$(shell sed -nE -e"0,/\[${aws_profile}\]/d" -e's/aws_secret_access_key[[:space:]=]*(.*)$$/\1/p' ~/.aws/credentials | head -1)\;
#	@echo 'if [ -z "$${AWS_ACCESS_KEY_ID}" -o -z "$${AWS_SECRET_ACCESS_KEY}" ]; then echo "Error fetching credentials" >&2; false; else true; fi'

validate: ## Validate terraform files
	@echo "Validating terraform files"
	@terraform validate .

check-version: ## Check terraform version for project
	@TF_VERSION=$$(terraform version | head -1 | cut -f 2 -d ' ') ; \
	TF_GIT_VERSION=$$(cat `git rev-parse --show-toplevel`/VERSION.txt) ; \
	if [ $$TF_VERSION != $$TF_GIT_VERSION ]; then \
        	echo "Aborted. Your TF version $$TF_VERSION not equal to project TF version - $$TF_GIT_VERSION" ; \
		exit 127; \
	fi

git-check: ## Check git remote state before apply
#	@git remote update
#	@if [ $$(git rev-list HEAD...origin/master --count) -ne 0 ]; then \
#		while [ -z "$$CONTINUE" ]; do \
#			read -r -p "Your branch is behind 'origin/master' by $$(git rev-list HEAD...origin/master --count) commits, continue? [yes/no] " CONTINUE; \
#			done ; \
#			if [ ! $$CONTINUE = "yes" ]; then \
#			echo "Aborted" ; \
#			exit 127; \
#			fi \
#	fi
#	@echo ""

git-env: ## Create new branch for own environment
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
ifeq "$(shell git rev-parse --abbrev-ref HEAD)" "$(ENVIRONMENT)"
	@echo "You already use $(ENVIRONMENT) branch" ; exit 10
endif

ifeq ("$(shell git show-ref refs/heads/$(ENVIRONMENT))","")
	@git checkout -b $(ENVIRONMENT)
else
	@git checkout $(ENVIRONMENT)
	@git stash apply stash@{0}
	@git stash drop stash@{0}
endif

git-master: ## Switch back to master branch
ifeq "$(shell git rev-parse --abbrev-ref HEAD)" "master"
	@echo "You already use master branch" ; exit 10
endif
	@git stash
	@git checkout master
	@git stash list
	@git remote update
	@if [ $$(git rev-list HEAD...origin/master --count) -ne 0 ]; then \
		echo "Your branch is behind 'origin/master' by $$(git rev-list HEAD...origin/master --count) commits." ; \
	fi
	@echo ""

git-merge: ## Merge own changes with master branch
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
	@git checkout master
	@git merge $(ENVIRONMENT)
	@echo "Use 'make git-clean' if merge was ok"

git-clean: ## Delete environmental branch
#	@if [ -z $(ENVIRONMENT) ]; then echo "ENVIRONMENT was not set" ; exit 10 ; fi
	@git branch -d $(ENVIRONMENT)

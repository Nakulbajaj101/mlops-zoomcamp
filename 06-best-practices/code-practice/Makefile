LOCAL_TAG:=$(shell date +"%Y-%m-%d-%H-%M")
export LOCAL_IMAGE_NAME:=stream-model-duration:${LOCAL_TAG}
quality_checks:
	find . -type f -name "*.py" | xargs pipenv run pylint
	pipenv run black .
	pipenv run isort .
	pipenv run pytest tests/ 

# Building local image
build_image:
	docker build -t ${LOCAL_IMAGE_NAME} .

# Run tests locally or in pipeline
integration_tests: build_image
	bash ./integration-test/run.sh

# Plan terraform stage
plan_stage:
	bash ./deploy/run_plan.sh stage

# Plan terraform prod
plan_prod:
	bash ./deploy/run_plan.sh prod

# Apply terraform stage local machine
apply_stage_local:
	bash ./deploy/run_apply_local.sh stage

# Apply terraform prod local machine
apply_prod_local:
	bash ./deploy/run_apply_local.sh prod

# Destroy terraform stage local machine
destroy_stage_local:
	bash ./deploy/run_destroy_local.sh stage

# Destroy terraform prod local machine
destroy_prod_local:
	bash ./deploy/run_destroy_local.sh prod

# Local image building and running integration tests
local_build_and_test: quality_checks
	bash ./integration-test/run.sh

# Test buiilding image locally and pushing to aws
local_publish: quality_checks integration_tests
	echo Publishing the image to AWS
	bash pushEcr.sh

# For local setup
setup:
	pipenv install --dev 
	pre-commit install
	
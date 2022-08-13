LOCAL_TAG:=$(shell date +"%Y-%m-%d-%H-%M")
export LOCAL_IMAGE_NAME:=stream-model-duration:${LOCAL_TAG}
quality_checks:
	find . -type f -name "*.py" | xargs pipenv run pylint
	pipenv run black .
	pipenv run isort .
	pipenv run pytest tests/ 

build_image:
	docker build -t ${LOCAL_IMAGE_NAME} .

integration_tests: build_image
	bash ./integration-test/run.sh

plan_stage:
	bash ./deploy/run_plan.sh stage

plan_prod:
	bash ./deploy/run_plan.sh prod

deploy_stage: 
	bash ./deploy/run_apply.sh stage

deploy_prod: 
	bash ./deploy/run_apply.sh prod

local_build_and_test: quality_checks
	bash ./integration-test/run.sh

local_publish: quality_checks integration_tests
	echo Publishing the image to AWS
	bash pushEcr.sh

publish_stage:
	bash pushEcr.sh stage

publish_prod:
	bash pushEcr.sh prod

setup:
	pipenv install --dev 
	pre-commit install
	
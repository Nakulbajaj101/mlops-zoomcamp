## Code snippets

[![CI_TESTS](https://github.com/Nakulbajaj101/mlops-zoomcamp/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/Nakulbajaj101/mlops-zoomcamp/actions/workflows/ci-tests.yml)

[![CD_DEPLOY](https://github.com/Nakulbajaj101/mlops-zoomcamp/actions/workflows/cd-deploy.yml/badge.svg)](https://github.com/Nakulbajaj101/mlops-zoomcamp/actions/workflows/cd-deploy.yml)

### Building and running Docker images

```bash
docker build -t stream-model-duration:v2 .
```

```bash
docker run -it --rm \
    -p 8080:8080 \
    -e STREAM_NAME="ride_predictions" \
    -e TEST_RUN="True" \
    stream-model-duration:v2
```

Mounting the model folder:

```bash
docker run -it --rm \
    -p 8080:8080 \
    -e STREAM_NAME="ride_predictions" \
    -e TEST_RUN="True" \
    -v integration-test/model:/app/model \
    stream-model-duration:v2
```

### Specifying endpoint URL

```bash
aws --endpoint-url=http://localhost:4566 \
    kinesis list-streams
```

```bash
aws --endpoint-url=http://localhost:4566 \
    kinesis create-stream \
    --stream-name ride_predictions \
    --shard-count 1
```

```bash
aws  --endpoint-url=http://localhost:4566 \
    kinesis     get-shard-iterator \
    --shard-id ${SHARD} \
    --shard-iterator-type TRIM_HORIZON \
    --stream-name ${PREDICTIONS_STREAM_NAME} \
    --query 'ShardIterator'
```

### Unable to locate credentials

If you get `'Unable to locate credentials'` error, add these
env variables to the `docker-compose.yaml` file in integration-test folder:

```yaml
- AWS_ACCESS_KEY_ID=abc
- AWS_SECRET_ACCESS_KEY=xyz
```

### Make

Without make:

```
find . -type f -name "*.py" | xargs pipenv run pylint
pipenv run black .
pipenv run isort .
pipenv run pytest tests/ 
```

With make:

```
make quality_checks
```


To prepare the project, run 

```bash
make setup
```


### IaC
w/ Terraform

#### Setup

**Installation**:

* [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (both versions are fine)
* [terraform client](https://www.terraform.io/downloads)

**Configuration**:

1. If you've already created an AWS account, head to the IAM section, generate your secret-key, and download it locally. 
[Instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html)

2. [Configure]((https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)) `aws-cli` with your downloaded AWS secret keys:
      ```shell
         $ aws configure
         AWS Access Key ID [None]: xxx
         AWS Secret Access Key [None]: xxx
         Default region name [None]: xxx 
         Default output format [None]:
      ```

3. Verify aws config:
      ```shell
        $ aws sts get-caller-identity
      ```

4. (Optional) Configuring with `aws profile`: [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html) and [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#using-an-external-credentials-process) 

<br>

#### Execution


1. To create infra (manually, in order to test on staging env)
    ```shell
    # Create infra from local and update lambda for stage
    make apply_stage_local

    # To create for prod
    make apply_prod_local
    ```

2. And then check on CloudWatch logs. Or try `get-records` on the `output_kinesis_stream` (refer to `integration_test`)

3. Destroy infra after use:
    ```shell
    # Delete infra after your work, to avoid costs on any running services
    make destroy_stage_local

    # For prod 
    make destroy_prod_local
    ```

<br>

### CI/CD

1. Create a PR (feature branch): `.github/workflows/ci-tests.yml`
    * Env setup, Unit test, Integration test, Terraform plan
2. Merge PR to `develop`: `.github/workflows/cd-deploy.yml`
    * Terraform plan, Terraform apply, Docker build & ECR push, Update Lambda config

### Notes

* Unfortunately, the `RUN_ID` (if set via the `ENV` or `ARG` in `Dockerfile`), disappears during lambda invocation.
We'll set it via `aws lambda update-function-configuration` CLI command (refer to `deploy_manual.sh` or `.github/workflows/cd-deploy.yml`)
    

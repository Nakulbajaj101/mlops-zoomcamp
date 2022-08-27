FROM public.ecr.aws/lambda/python:3.9

ARG STREAM_NAME_ARG="ride_predictions"
ARG RUN_ID_ARG="20c7e3f3b3584b769bf6cacd4643d43d"
ARG TEST_RUN_ARG=False
ARG MODEL_BUCKET_ARG="mlops-zoomcamp-nakul-dev"

ENV STREAM_NAME=$STREAM_NAME_ARG
ENV RUN_ID=$RUN_ID_ARG
ENV TEST_RUN=$TEST_RUN_ARG
ENV MODEL_BUCKET=$MODEL_BUCKET_ARG

RUN pip install -U pip
RUN pip install pipenv==2022.8.5

COPY ["Pipfile", "Pipfile.lock", "./"]

RUN pipenv install --system --deploy

COPY [ "lambda_function.py", "model.py", "./" ]

CMD [ "lambda_function.lambda_handler" ]

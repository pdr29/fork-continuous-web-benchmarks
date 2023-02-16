FROM google/cloud-sdk:alpine

RUN apk add --no-cache openjdk8 unzip

# Install client application
WORKDIR /opt/bench/

COPY run.sh /opt/bench/

ENV PROJECT_ID=default
ENV BUCKET=default

EXPOSE 8080

CMD ["sh", "-c", "/opt/bench/run.sh ${PROJECT_ID} ${BUCKET}"]
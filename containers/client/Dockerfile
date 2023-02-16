FROM google/cloud-sdk:alpine

RUN apk add --no-cache openjdk8 unzip

# Install client application
WORKDIR /opt/bench/

RUN curl -LsS https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.0/gatling-charts-highcharts-bundle-3.9.0-bundle.zip > gatling.zip \
      && unzip gatling.zip && mv gatling-charts-highcharts-bundle-3.9.0 gatling \
      && rm -rf gatling/user-files/simulations gatling.zip
    
COPY gatling/ /opt/bench/gatling/user-files/
COPY run.sh /opt/bench/

# Replace with inline env variables when running the container
ENV SERVER_HOST=localhost:8080
ENV SIMULATIONS="TextPlain"
ENV INCREMENT=128
ENV STEPS=8
ENV BUCKET=default

CMD ["sh", "-c", "/opt/bench/run.sh ${SERVER_HOST} ${SIMULATIONS} ${INCREMENT} ${STEPS}"]
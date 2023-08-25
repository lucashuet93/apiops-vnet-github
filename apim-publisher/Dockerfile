FROM --platform=linux/amd64  debian:12.1-slim
ARG APIM_VERSION=v4.9.0
ENV APIM_VERSION $APIM_VERSION

RUN apt update -qq \
    && apt install -qq -y wget libicu72

RUN wget https://github.com/Azure/apiops/releases/download/${APIM_VERSION}/publisher.linux-x64.exe -O /usr/local/bin/publisher \
    && chmod +x /usr/local/bin/publisher

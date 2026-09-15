FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config \
    libgtk-3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter && \
    /opt/flutter/bin/flutter config --no-analytics && \
    /opt/flutter/bin/flutter precache

ENV PATH="/opt/flutter/bin:${PATH}"

USER ubuntu

FROM ubuntu:22.04

LABEL org.opencontainers.image.title="stm32-test"
LABEL org.opencontainers.image.description="Build and test environment for STM32 firmware unit tests (GCC, CMake, lcov)"
LABEL org.opencontainers.image.source="https://github.com/koao/docker-stm32-test"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libperlio-gzip-perl libjson-perl wget ca-certificates \
    && wget -q https://github.com/Kitware/CMake/releases/download/v3.28.6/cmake-3.28.6-linux-x86_64.sh \
    && sh cmake-3.28.6-linux-x86_64.sh --skip-license --prefix=/usr/local \
    && rm cmake-3.28.6-linux-x86_64.sh \
    && wget -q http://archive.ubuntu.com/ubuntu/pool/universe/l/lcov/lcov_1.14-2_all.deb \
    && dpkg -i lcov_1.14-2_all.deb && rm lcov_1.14-2_all.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Build-Stage
FROM debian:bookworm-slim AS builder

# Set build arguments for RTL-SDR version, build date, and VCS reference
ARG RTLSDR_VERSION="v2.0.2"
ARG BUILD_DATE="unknown"
ARG VCS_REF="unknown"

  # Set environment variable for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package repository and install necessary packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libfftw3-dev \
    libusb-1.0-0-dev \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    # Clone the RTL-SDR repository from Osmocom and checkout the specified version
RUN git clone https://gitea.osmocom.org/sdr/rtl-sdr.git /rtl-sdr && \
    cd /rtl-sdr && \
    git checkout $RTLSDR_VERSION

WORKDIR /rtl-sdr

# Compile RTL-SDR from source
# https://osmocom.org/projects/rtl-sdr/wiki
RUN mkdir build && cd build && \
    cmake ../ && \
    make && \
    make install && \
    ldconfig


# Runtime Stage
FROM debian:bookworm-slim

LABEL org.label-schema.schema-version="1.0" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="legacycode/rtlsdr" \
    org.label-schema.description="A Docker image based on Deian Linux ready to run any rtl_sdr command!" \
    org.label-schema.usage="https://hub.docker.com/r/legacycode/rtlsdr" \
    org.label-schema.url="https://hub.docker.com/r/legacycode/rtlsdr" \
    org.label-schema.vcs-url="https://github.com/legacycode/rtlsdr-docker" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.version=$RTLSDR_VERSION \
    maintainer="info@legacycode.org"
  
# Install only the necessary runtime dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    libusb-1.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the compiled binaries and library files from the builder stage to the runtime stage
COPY --from=builder /usr/local/bin/rtl_* /usr/local/bin/
COPY --from=builder /usr/local/lib/librtlsdr.* /usr/local/lib/

# Update the library cache
RUN ldconfig

# Set the default command to run when the container starts
CMD ["rtl_test"]

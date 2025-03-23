FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ARG dovitoollink="https://github.com/quietvoid/dovi_tool/releases/download/1.4.6/dovi_tool-1.4.6-x86_64-unknown-linux-musl.tar.gz"
ARG hdr10plustoollink="https://github.com/quietvoid/hdr10plus_tool/releases/download/1.2.2/hdr10plus_tool-1.2.2-x86_64-unknown-linux-musl.tar.gz"
ARG dotnetlink="https://download.visualstudio.microsoft.com/download/pr/48fbc600-8228-424e-aaed-52b7e601c277/c493b8ac4629341f1e5acc4ff515fead/dotnet-runtime-6.0.10-linux-x64.tar.gz"
ARG pgs2srtlink="https://github.com/Tentacule/PgsToSrt/releases/download/v1.4.2/PgsToSrt-1.4.2.zip"
ARG tesseractlink="https://github.com/tesseract-ocr/tessdata.git"
COPY dvmkv2mp4 /usr/local/bin
RUN chmod a+x /usr/local/bin/dvmkv2mp4

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    software-properties-common \
    ca-certificates \
    ffmpeg \
    jq \
    bc \
    unzip \
    libtesseract4

# Add GPAC PPA and install MP4Box from there
RUN add-apt-repository ppa:gpac/gpac-daily && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gpac

# Enable universe repository for mediainfo and mkvtoolnix
RUN add-apt-repository -y universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    mediainfo \
    mkvtoolnix

# DOVI_TOOL
RUN wget -O - ${dovitoollink} | \
    tar -zx -C /usr/local/bin/

# HDR10PLUS_TOOL
RUN wget -O - ${hdr10plustoollink} | \
    tar -zx -C /usr/local/bin/ && \
    if [ -d "/usr/local/bin/dist" ]; then \
        mv /usr/local/bin/dist/* /usr/local/bin/; \
    fi

# PGS2SRT
RUN mkdir -p /opt/dotnet && \
    wget -O - ${dotnetlink} | \
    tar -zx -C /opt/dotnet/ && \
    mkdir -p /opt/PgsToSrt && \
    wget ${pgs2srtlink} -O temp.zip && \
    unzip -d /opt/PgsToSrt/ temp.zip && \
    rm temp.zip && \
    cd /opt/PgsToSrt/net6 && \
    git clone --depth 1 ${tesseractlink}

# Check MP4Box version
RUN MP4Box -version

# Clean up
RUN apt-get purge -y \
    software-properties-common \
    unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Create the volume mount point
RUN mkdir -p /convert
VOLUME ["/convert"]
WORKDIR /convert
ENTRYPOINT ["dvmkv2mp4"]
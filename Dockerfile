FROM ubuntu:20.04
ARG mediainforepo="https://mediaarea.net/repo/deb/repo-mediaarea_1.0-19_all.deb"
ARG dovitoollink="https://github.com/quietvoid/dovi_tool/releases/download/1.4.6/dovi_tool-1.4.6-x86_64-unknown-linux-musl.tar.gz"
ARG hdr10plustoollink="https://github.com/quietvoid/hdr10plus_tool/releases/download/1.2.2/hdr10plus_tool-1.2.2-x86_64-unknown-linux-musl.tar.gz"
ARG mp4boxlink="https://github.com/gpac/gpac.git"
ARG mp4boxtag="v1.0.1"
ARG dotnetlink="https://download.visualstudio.microsoft.com/download/pr/48fbc600-8228-424e-aaed-52b7e601c277/c493b8ac4629341f1e5acc4ff515fead/dotnet-runtime-6.0.10-linux-x64.tar.gz"
ARG pgs2srtlink="https://github.com/Tentacule/PgsToSrt/releases/download/v1.4.2/PgsToSrt-1.4.2.zip"
ARG tesseractlink="https://github.com/tesseract-ocr/tessdata.git"

COPY dvmkv2mp4 /usr/local/bin
RUN chmod a+x /usr/local/bin/dvmkv2mp4

# Install MEDIAINFO MKVTOOLNIX FFMPEG WGET
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates && \
    add-apt-repository -y ppa:jonathonf/ffmpeg-4 && \
    wget -O /usr/share/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ focal main" | tee -a /etc/apt/sources.list && \
    wget ${mediainforepo} -O temp.deb && \
    dpkg -i temp.deb && \
    rm temp.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    mediainfo \
    mkvtoolnix \
    jq \
    bc

# DOVI_TOOL
RUN wget -O - ${dovitoollink} | \
    tar -zx -C /usr/local/bin/

# HDR10PLUS_TOOL
RUN wget -O - ${hdr10plustoollink} | \
    tar -zx -C /usr/local/bin/ && \
    mv /usr/local/bin/dist/* /usr/local/bin/ || true

# MP4BOX
RUN apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    git \
    zlib1g-dev && \
    mkdir mp4box && \
    cd mp4box && \
    git clone --depth 1 --branch ${mp4boxtag} ${mp4boxlink} gpac_public && \
    cd gpac_public && \
    ./configure --static-bin && \
    make -j $(nproc) && \
    make install && \
    MP4Box -version && \
    cd ../.. && \
    rm -Rf mp4box

# PGS2SRT
RUN mkdir -p /opt/dotnet && \
    wget -O - ${dotnetlink} | \
    tar -zx -C /opt/dotnet/ && \
    apt-get install -y --no-install-recommends \
    libtesseract4 \
    unzip \
    git && \
    mkdir -p /opt/PgsToSrt && \
    wget ${pgs2srtlink} -O temp.zip && \
    unzip -d /opt/PgsToSrt/ temp.zip && \
    rm temp.zip && \
    cd /opt/PgsToSrt/net6 && \
    git clone --depth 1 ${tesseractlink} && \
    apt-get purge -y \
    software-properties-common \
    build-essential \
    pkg-config \
    git \
    zlib1g-dev \
    unzip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Create the volume mount point
RUN mkdir /convert
VOLUME ["/convert"]
WORKDIR /convert
ENTRYPOINT ["dvmkv2mp4"]
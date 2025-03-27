# dvmkv2mp4 - Convert any Dolby Vision/HDR10+ MKV to MP4

Converts any Dolby Vision (Profile 5, 7 Single Track, 7 Dual Track, 8) / HDR10+ mkv to mp4 (DV4, DV5, DV8) compatible with LG OLEDs, Nvidia Shield and possibly more tested with Emby on LG 77CX, 48CX, 65C8.

## Features

- Autodetects source material and chooses proper workflow
- Converting from any 5,7,8 DV profile to DV mp4
- Converting from HDR10+ to DV8 mp4
- Verifies HDR10+ metadata before conversion (lots of fake releases out there)
- Converts any truehd, dts etc to high bitrate Dolby Digital Plus, copies without conversion supported tracks like ac3, eac3
- Keeps audio/subtitle track delays in resulting mp4
- Keeps chapters
- Converts PGS subtitles found to SRT subtitles with PGSToSrt
- Extracts all SRT/Subrip tracks to SRT files
- Can inject subtitles into mp4 as subtitle tracks
- Can create backup mkv with .asm extension (audio subs meta) that has the original audio (truehd etc) subtitles tracks, chapters but without video to safekeep for future comeback conversions to original mkv and not waste place as you can easily demux the mp4 video and mux it with that mkv to come back to original
- Can filter and leave only desired language tracks
- MacOS support
- Process a single file instead of all files in a directory
- Mobile optimization option for iPhone and Android playback

## Requirements

- ffmpeg 4.4
- **mp4box 2.0.0 - it's important to use this version otherwise script will fail**
- dovi_tool
- hdr10plus_tool
- mediainfo v21
- dotnet6 for PGS2SRT conversion
- 3xSize of free space for file you want to convert
- jq, bc

## Installation

### Requirements installation on Ubuntu 20.04

```bash
# MEDIAINFO MKVTOOLNIX FFMPEG
sudo add-apt-repository ppa:savoury1/ffmpeg4
sudo wget -O /usr/share/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ focal main" | sudo tee -a /etc/apt/sources.list
wget https://mediaarea.net/repo/deb/repo-mediaarea_1.0-19_all.deb && sudo dpkg -i repo-mediaarea_1.0-19_all.deb && sudo apt-get update
sudo apt-get install ffmpeg mediainfo mkvtoolnix jq bc

# DOVI_TOOL
wget https://github.com/quietvoid/dovi_tool/releases/download/1.4.6/dovi_tool-1.4.6-x86_64-unknown-linux-musl.tar.gz
tar -zxf dovi_tool-1.4.6-x86_64-unknown-linux-musl.tar.gz
sudo mv dist/dovi_tool /usr/local/bin/

# HDR10PLUS_TOOL
wget https://github.com/quietvoid/hdr10plus_tool/releases/download/1.2.2/hdr10plus_tool-1.2.2-x86_64-unknown-linux-musl.tar.gz
tar -zxf hdr10plus_tool-1.2.2-x86_64-unknown-linux-musl.tar.gz
sudo mv dist/hdr10plus_tool /usr/local/bin/

# MP4BOX
sudo apt-get install build-essential pkg-config git
sudo apt-get install zlib1g-dev
git clone --depth 1 --branch v2.0.0 https://github.com/gpac/gpac.git gpac_public
cd gpac_public
./configure --static-bin
make
sudo make install
MP4Box -version # MAKE SURE IT SAYS 2.0.0

# PGS2SRT
wget https://download.visualstudio.microsoft.com/download/pr/48fbc600-8228-424e-aaed-52b7e601c277/c493b8ac4629341f1e5acc4ff515fead/dotnet-runtime-6.0.10-linux-x64.tar.gz
tar -zxf dotnet-runtime-6.0.10-linux-x64.tar.gz
sudo mkdir /opt/dotnet
sudo mv * /opt/dotnet
cd /opt
sudo apt install libtesseract4
sudo mkdir /opt/PgsToSrt
cd /opt/PgsToSrt
sudo wget https://github.com/Tentacule/PgsToSrt/releases/download/v1.4.2/PgsToSrt-1.4.2.zip
sudo unzip PgsToSrt-1.4.2.zip
cd net6
sudo git clone --depth 1 https://github.com/tesseract-ocr/tessdata.git
```

### Script Installation

Download dvmkv2mp4, make it executable, and move to bin:

```bash
wget https://raw.githubusercontent.com/gacopl/dvmkv2mp4/main/dvmkv2mp4
chmod a+x dvmkv2mp4
sudo mv dvmkv2mp4 /usr/local/bin/
```

### MacOS Installation

#### Requirements install on MacOS

Multiple installations and modifications are needed before being able to run the tool on MacOS.

##### FFMPEG@4

In order to be compatible with other modules of the project you need to install the version 4.X.X of ffmpeg and not the last one.
You can do this by running the command:

```bash
brew install ffmpeg@4
```

In order to use ffmpeg command or use `ffmpeg@4` when using `ffmpeg` command (instead of newer version maybe installed on your mac) you need to run the following commands.
If you are on macOS Catalina and later:

```bash
# Add ffmpeg@4 to PATH using redirection
echo 'export PATH="/usr/local/opt/ffmpeg@4/bin:$PATH"' >> ~/.zshrc
```

If you are on older macOS versions:

```bash
# Add ffmpeg@4 to PATH using redirection
echo 'export PATH="/usr/local/opt/ffmpeg@4/bin:$PATH"' >> ~/.bash_profile
```

Check your ffmpeg version:

```bash
ffmpeg -version
```

You should be in 4.X.X

##### Multiple modules installations (MEDIAINFO, JQ, DOVI_TOOL)

```bash
# MEDIAINFO
brew install mediainfo
# JQ
brew install jq
# DOVI_TOOL
brew install dovi_tool
```

##### HDR10PLUS_TOOL

Go to the last release to this date and download the universal-macOS zip (here it's 1.6.1): https://github.com/quietvoid/hdr10plus_tool/releases/tag/1.6.1
There might be new releases when you will read this and they might work but 1.6.1 works for sure.
Unzip the file to extract the executable file that should be named: `hdr10plus_tool`
Make sure your file is executable and move it to your `/usr/local/bin`:

```bash
sudo cp ~/Downloads/hdr10plus_tool /usr/local/bin
chmod a+x /usr/local/bin/hdr10plus_tool
```

##### MP4BOX

MP4BOX is probably the most trickiest module to install, several steps are needed:

###### XQuartz / X11

You need first to install XQuartz in order to be compatible with X11.
Go to https://www.xquartz.org/ to download and install XQuartz for your Mac.

###### GPAC / MP4BOX

As mentioned before only v1.0.1 is compatible with the tool.
To install v1.0.1 please execute the following steps:

```bash
# Clone the v1.0.1 version of the module
git clone --depth 1 --branch v1.0.1 https://github.com/gpac/gpac.git gpac_public

# Go into the folder
cd gpac_public

# Build and install the module to your mac
./configure --static-bin
make
sudo make install

# When the install is successfull you can check the version and make sure it's 1.0.1
MP4Box -version
```

##### .NET6 for PGS2SRT

Go to Microsoft website to download the last .NET 6 runtime binaries: https://dotnet.microsoft.com/fr-fr/download/dotnet/6.0
If your mac is a M1, M2, etc.. choose `Arm64`, if not choose `x64`.
**Only binaries are needed do not download the full sdk**.
Then create a `dotnet` folder inside your `/opt` folder:

```bash
cd /opt
sudo mkdir dotnet
```

Then copy the binaries iside the .net runtime folder that you extracted from the tar.gz into the /opt/dotnet folder:

```bash
# Replace the folder in Downloads by the one you extracted
sudo mv ~/Downloads/dotnet-runtime-6.0.35-osx-x64/* /opt/dotnet
```

Create a PgsToSrt folder in /opt and then a net6 folder inside:

```bash
cd /opt
sudo mkdir PgsToSrt
cd PgsToSrt
sudo mkdir net6
```

Download the PGS2SRT package: https://github.com/Tentacule/PgsToSrt/releases/tag/v1.4.5
Extract the package and then navigate in your terminal to be in the extracted folder of the package:

```bash
# Replace the folder in Downloads by the one you extracted
cd ~/Downloads/PgsToStr-1.4.5
```

Clone the tessdata inside the folder:

```bash
sudo git clone --depth 1 https://github.com/tesseract-ocr/tessdata.git
```

And then copy all the data in the folder to `/opt/PgsToSrt/net6`:

```bash
sudo cp * /opt/PgsToSrt/net6
```

##### IONICE-MACOS

Download the release zip package: https://github.com/DrHyde/ionice-MacOS/releases/tag/release-1
And extract it.
In order to make it work you need to **modify the Makefile** in the folder.
Replace first line with:

```bash
PREFIX=/usr/local
```

And last two lines with:

```bash
clean:
	rm -f ionice ionice.1
```

Now you can run the following command in the ionice folder to install the module:

```bash
sudo make install
```

##### GNU-SED

```bash
# Install package
brew install gnu-sed
# Make it executable as sed
PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
```

## Usage

In a directory containing Dolby Vision mkv files, simply run:

```bash
dvmkv2mp4
```

It will process any mkvs found in that directory.

Options:

- `-l | --langs` - Filter audio and subtitle tracks by language comma separated if not hit by filter keep all tracks
- `-a | --asm` - Create audio-subs-meta mkv file
- `-r | --remove-source` - Remove source video after conversion
- `-s | --add-subs` - Add srt subtitles to mp4 as subtitle tracks
- `-d | --debug` - Keep intermediary conversion files
- `-f | --file` - Process a single file instead of all MKVs in directory
- `-v | --version` - Print version

Examples:

```bash
# Process all files in directory, keep only undefined, Polish, and English tracks
# Also remove source files and create audio-subs-meta files
dvmkv2mp4 -l und,pol,eng -r -a

# Process a single file with English and Japanese audio tracks
dvmkv2mp4 -f movie.mkv -l eng,jpn

# Process a single file and add subtitles to the MP4
dvmkv2mp4 -f movie.mkv -s
```

## Docker

Pull the Docker image and run it with your MKV files:

```bash
# Pull the image
docker pull ghcr.io/regix1/dvmkv2mp4:main

# Process all MKV files in a directory
docker run -v /path/to/your/videos:/convert ghcr.io/regix1/dvmkv2mp4:main

# Process a single file 
docker run -v /path/to/your/videos:/convert ghcr.io/regix1/dvmkv2mp4:main -f movie.mkv

# Process with advanced options
docker run -v /path/to/your/videos:/convert ghcr.io/regix1/dvmkv2mp4:main -l eng,jpn -a -r
```

## Roadmap

- GitHub action to build ready docker images for pulling (completed!)
- On MP4Box fail rerun with -no-probe switch which works with stubborn releases
- Helper scripts for Radarr, Sonarr to automatically run on import
- Convert directly from Bluray bdmv mpls file (have it working in alpha state already)

## Shoutouts

- To @quietvoid for dovi_tool and hdr10plus_tool - this whole thing wouldn't be possible without him
- To @szasza576 for dockerfile
- To makeMKV and avsForum for inspiration to work it out and put it all together

## Disclaimer

This is a hobby project created by personal need. It could be A LOT better written (I hate those evals) but priority was to make it fast. I code a lot at work so I mostly choose to spend free time with kids and watching movies over this I have a life you know :)

Therefore I didn't have nor wanted to spend too much time on it so don't judge the code quality. I did some features for You though beta was working already fine for me, I wanted to give back something to community.

PRs are welcome :)

Original project by gacopl
Single file option added by regix1

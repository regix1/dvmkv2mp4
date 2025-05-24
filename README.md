# dvmkv2mp4 v0.4.0 - Convert any Dolby Vision/HDR10+ MKV to MP4

Converts any Dolby Vision (Profile 4, 5, 7 Single Track, 7 Dual Track, 8) / HDR10+ mkv to mp4 (DV4, DV5, DV8) compatible with LG OLEDs, Nvidia Shield and possibly more tested with Emby on LG 77CX, 48CX, 65C8.

## ✨ New in v0.4.0

- **🎯 DV7→DV4 Conversion**: Convert Dolby Vision Profile 7 to Profile 4 for maximum device compatibility
- **🛡️ Enhanced Error Handling**: Robust dependency checking, file validation, and error recovery
- **📊 Better Progress Reporting**: Detailed logging and status updates throughout the conversion process
- **🧹 Improved Cleanup**: Reliable temporary file management with automatic cleanup on exit
- **⚡ Performance Optimizations**: Streamlined processing and reduced memory usage

## Features

- **Autodetects source material** and chooses proper workflow
- **Converting from any 4,5,7,8 DV profile** to DV mp4
- **NEW: DV7→DV4 conversion** for maximum compatibility with older devices
- **Converting from HDR10+ to DV8** mp4
- **Verifies HDR10+ metadata** before conversion (lots of fake releases out there)
- **Advanced audio processing**: Converts any truehd, dts etc to high bitrate Dolby Digital Plus, copies without conversion supported tracks like ac3, eac3
- **Preserves timing**: Keeps audio/subtitle track delays in resulting mp4
- **Chapter support**: Maintains chapter information
- **Subtitle conversion**: Converts PGS subtitles found to SRT subtitles with PGSToSrt
- **Subtitle extraction**: Extracts all SRT/Subrip tracks to SRT files
- **Subtitle injection**: Can inject subtitles into mp4 as subtitle tracks
- **Backup creation**: Can create backup mkv with .asm extension (audio subs meta) that has the original audio (truehd etc) subtitles tracks, chapters but without video
- **Language filtering**: Can filter and leave only desired language tracks
- **Cross-platform**: MacOS and Linux support
- **Single file processing**: Process a single file instead of all files in a directory
- **File output info**: Integration with FileFlows and other automation tools

## DV7→DV4 Conversion

The new `-4` flag converts Dolby Vision Profile 7 content to Profile 4 for broader device compatibility.

### When to use DV7→DV4 conversion:

- **Device compatibility**: Target devices don't support DV7 (many older TVs, mobile devices, streaming sticks)
- **Streaming optimization**: Reduce file sizes for better streaming performance
- **Legacy support**: Ensure playback on older Dolby Vision-capable devices

### What happens during conversion:

- **Extracted**: Base layer (BL) and enhancement layer (EL) from DV7
- **Converted**: RPU metadata from profile 7 to profile 4
- **Color space**: Automatic BT.2020 → BT.709 conversion when needed
- **Compatibility**: Creates DV4 MP4 that works on significantly more devices

### Trade-offs:

- **❌ Lost**: Enhancement layer data, extended color gamut (BT.2020 → BT.709)
- **✅ Gained**: Much broader device compatibility, smaller file sizes, better streaming performance

## Requirements

- **ffmpeg 4.4+**
- **MP4Box 2.0.0+** - Important: Use this version or newer for proper DV support
- **dovi_tool 1.4.6+**
- **hdr10plus_tool 1.2.2+**
- **mediainfo v21+**
- **dotnet6** for PGS2SRT conversion
- **3x file size** of free space for conversion
- **jq, bc** for JSON processing and calculations

## Installation

### Requirements installation on Ubuntu 20.04/22.04

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
MP4Box -version # MAKE SURE IT SAYS 2.0.0 or newer

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

Go to the latest release and download the universal-macOS zip: https://github.com/quietvoid/hdr10plus_tool/releases/latest
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

As mentioned before only v2.0.0+ is compatible with the tool.
To install v2.0.0 please execute the following steps:

```bash
# Clone the v2.0.0 version of the module
git clone --depth 1 --branch v2.0.0 https://github.com/gpac/gpac.git gpac_public

# Go into the folder
cd gpac_public

# Build and install the module to your mac
./configure --static-bin
make
sudo make install

# When the install is successful you can check the version and make sure it's 2.0.0+
MP4Box -version
```

##### .NET6 for PGS2SRT

Go to Microsoft website to download the latest .NET 6 runtime binaries: https://dotnet.microsoft.com/fr-fr/download/dotnet/6.0
If your mac is a M1, M2, etc.. choose `Arm64`, if not choose `x64`.
**Only binaries are needed do not download the full sdk**.
Then create a `dotnet` folder inside your `/opt` folder:

```bash
cd /opt
sudo mkdir dotnet
```

Then copy the binaries inside the .net runtime folder that you extracted from the tar.gz into the /opt/dotnet folder:

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

Download the PGS2SRT package: https://github.com/Tentacule/PgsToSrt/releases/latest
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

### Command Line Options

- `-l | --langs` - Filter audio and subtitle tracks by language comma separated if not hit by filter keep all tracks
- `-a | --asm` - Create audio-subs-meta mkv file
- `-r | --remove-source` - Remove source video after conversion
- `-s | --add-subs` - Add srt subtitles to mp4 as subtitle tracks
- `-d | --debug` - Keep intermediary conversion files
- `-f | --file` - Process a single file instead of all MKVs in directory
- `-o | --file-output` - Output file information (filename, file, path) for automation tools
- `-4 | --force-dv4` - **NEW**: Convert all DV content to DV4 for maximum compatibility
- `-v | --version` - Print version
- `-h | --help` - Show help message

### Examples

#### Basic Usage

```bash
# Process all files in directory
dvmkv2mp4

# Process a single file
dvmkv2mp4 -f movie.mkv

# Process with debug mode to see intermediate files
dvmkv2mp4 -f movie.mkv -d
```

#### DV7→DV4 Conversion (NEW)

```bash
# Convert DV7 file to DV4 for maximum compatibility
dvmkv2mp4 -4 -f movie_dv7.mkv

# Process all files and convert any DV7 to DV4
dvmkv2mp4 -4

# Convert DV7 to DV4 with English tracks only
dvmkv2mp4 -4 -l eng -f movie_dv7.mkv
```

#### Advanced Processing

```bash
# Process all files in directory, keep only undefined, Polish, and English tracks
# Also remove source files and create audio-subs-meta files
dvmkv2mp4 -l und,pol,eng -r -a

# Process a single file with English and Japanese audio tracks
dvmkv2mp4 -f movie.mkv -l eng,jpn

# Process a single file and add subtitles to the MP4
dvmkv2mp4 -f movie.mkv -s

# Full processing with all options including DV7→DV4 conversion
dvmkv2mp4 -4 -l eng,und -r -s -a -f movie_dv7.mkv
```

#### Automation Integration

```bash
# For FileFlows integration
dvmkv2mp4 -f movie.mkv -o

# Batch processing with error recovery
dvmkv2mp4 -4 -l eng -r -d  # Keep debug files for troubleshooting
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

# Process with DV7→DV4 conversion
docker run -v /path/to/your/videos:/convert ghcr.io/regix1/dvmkv2mp4:main -4 -f movie.mkv

# Process with advanced options
docker run -v /path/to/your/videos:/convert ghcr.io/regix1/dvmkv2mp4:main -4 -l eng,jpn -a -r
```

## Compatibility Matrix

| Source Format | Output Format | Compatibility |
|---------------|---------------|---------------|
| DV Profile 4  | DV4 MP4      | ✅ Universal   |
| DV Profile 5  | DV5 MP4      | ✅ High        |
| DV Profile 7  | DV7 MP4      | ⚠️ Limited     |
| DV Profile 7  | **DV4 MP4** (with `-4`) | ✅ Universal |
| DV Profile 8  | DV8 MP4      | ✅ High        |
| HDR10+        | DV8 MP4      | ✅ High        |

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Run the script - it will check for missing tools and report them
2. **MP4Box version**: Ensure you're using MP4Box 2.0.0 or newer
3. **File permissions**: Make sure the script has write permissions in the working directory
4. **Insufficient space**: Ensure you have at least 3x the source file size in free space

### Debug Mode

Use `-d` flag to keep intermediate files for troubleshooting:

```bash
dvmkv2mp4 -d -f problematic_file.mkv
```

This will preserve all intermediate files so you can inspect what went wrong.

## Roadmap

- ✅ **GitHub action to build ready docker images for pulling (completed!)**
- ✅ **DV7→DV4 conversion for maximum compatibility (completed!)**
- ✅ **Enhanced error handling and validation (completed!)**
- 🔄 **On MP4Box fail rerun with -no-probe switch** which works with stubborn releases
- 🔄 **Helper scripts for Radarr, Sonarr** to automatically run on import
- 🔄 **Convert directly from Bluray bdmv mpls file** (have it working in alpha state already)
- 🔄 **AV1 Dolby Vision support** when dovi_tool adds support

## Performance Tips

- **SSD storage**: Use SSD for temporary files to speed up processing
- **RAM**: Ensure sufficient RAM (8GB+ recommended for 4K content)
- **CPU**: Multi-core processors significantly reduce processing time
- **Debug mode**: Only use `-d` flag when troubleshooting to avoid extra I/O

## Shoutouts

- To **@quietvoid** for dovi_tool and hdr10plus_tool - this whole thing wouldn't be possible without him
- To **@szasza576** for dockerfile
- To **makeMKV and avsForum** for inspiration to work it out and put it all together
- To the **community** for testing, feedback, and feature requests

## Disclaimer

This is a hobby project created by personal need. It could be A LOT better written (I hate those evals) but priority was to make it fast. I code a lot at work so I mostly choose to spend free time with kids and watching movies over this I have a life you know :)

Therefore I didn't have nor wanted to spend too much time on it so don't judge the code quality. I did some features for You though beta was working already fine for me, I wanted to give back something to community.

PRs are welcome :)

## Contributors

- **Original project by gacopl**
- **Single file option added by regix1**
- **DV7→DV4 conversion and enhanced error handling by community**

---

**Note**: DV7→DV4 conversion involves quality trade-offs. Test with your specific content and playback devices to determine if the compatibility benefits outweigh the quality loss for your use case.

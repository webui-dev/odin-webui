#!/usr/bin/env bash

# Determine the release archive for the used platform and architecture.
platform=$(uname -s)
arch=$(uname -m)
case "$platform" in
	Linux)
		case "$arch" in
			x86_64)
				archive="webui-linux-gcc-x64.zip"
				;;
			aarch64|arm64)
				archive="webui-linux-gcc-arm64.zip"
				;;
			arm*)
				archive="webui-linux-gcc-arm.zip"
				;;
			*)
				echo "The setup script currently does not support $arch architectures on $platform."
				exit 1
				;;
		esac
		;;
	Darwin)
		case "$arch" in
			x86_64)
				archive="webui-macos-clang-x64.zip"
				;;
			arm64)
				archive="webui-macos-clang-arm64.zip"
				;;
			*)
				echo "The setup script currently does not support $arch architectures on $platform."
				exit 1
				;;
		esac
		;;
	*)
		echo "The setup script currently does not support $platform."
		exit 1
		;;
esac

# Parse CLI arguments.
# Defaults.
output="$(dirname  $0)/webui"
version="latest"
while [ $# -gt 0 ]; do
	case "$1" in
		-o|--output)
			output="$2"
			shift
			;;
		--nightly)
			version="nightly"
			shift
			;;
		-h|--help)
			echo -e "Usage: setup.sh [flags]\n"
			echo "Flags:"
			echo "  -o, --output: Specify the output directory"
			echo "  --nightly: Download the development release"
			echo "  -h, --help: Display this help message"
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			exit 1
			;;
	esac
done

# Clean old library files.
# rm -rf "$output/include/webui.h" "$output/include/webui.hpp" \
# 	"$output/debug/libwebui-2-static.a" "$output/debug/webui-2.dylib" "$output/debug/webui-2.dll" \
# 	"$output/libwebui-2-static.a" "$output/webui-2.dylib" "$output/webui-2.dll"
rm -rf "$output"

release_base_url="https://github.com/webui-dev/webui/releases/"
if [ "$version" = "nightly" ]; then
	url="$release_base_url/download/nightly/$archive"
elif [ "$version" = "latest" ]; then
	url="$release_base_url/latest/download/$archive"
fi

# Download and extract the archive.
echo "Downloading WebUI@$version..."
curl -L "$url" -o "$archive"
echo ""

echo "Extracting..."
archive_dir="${archive%.zip}"
unzip "$archive"
mv "$archive_dir" "$output"
echo ""

# Clean downloaded files and residues.
rm -f "$archive"
rm -rf "$output/$archive_dir"

echo "Done."

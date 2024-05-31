# Store the current location to restore it at the end of the script.
$current_location = Get-Location

# Determine the release archive for the used platform and architecture.
# For this Windows script this is currently only x64.
$platform = [System.Environment]::OSVersion.Platform
$architecture = [System.Environment]::Is64BitOperatingSystem
switch -wildcard ($platform)
{
	"Win32NT"
	{
		switch -wildcard ($architecture)
		{
			"True"
			{
				$archive = "webui-windows-msvc-x64.zip"
			}
			default
			{
				Write-Host "The setup script currently does not support $arch architectures on Windows."
				exit 1
			}
		}
	}
	default
	{
		Write-Host "The setup script currently does not support $platform."
		exit 1
	}
}

# Parse CLI arguments.
# Defaults
$output = Join-Path $PSScriptRoot "webui"
# Default to `nightly` until WebUI 2.5.0 release. Earlier versions do not support odin-webui.
$version = "nightly"
for ($i = 0; $i -lt $args.Length; $i++)
{
	switch -wildcard ($args[$i])
	{
		'--output'
		{
			$output = $args[$i + 1]
			$i++
			break
		}
		'--nightly'
		{
			$version = "nightly"
			break
		}
		'--help'
		{
			Write-Host "Usage: setup.ps1 [flags]"
			Write-Host ""
			Write-Host "Flags:"
			Write-Host "  -o, --output: Specify the output directory"
			Write-Host "  --nightly: Download the latest nightly release"
			Write-Host "  -h, --help: Display this help message"
			exit 0
		}
		default
		{
			Write-Host "Unknown option: $($args[$i])"
			exit 1
		}
	}
}

$archive_dir = $archive.Replace(".zip", "")

# Clean old library files in case they exist.
Remove-Item -Path $archive -ErrorAction SilentlyContinue
Remove-Item -Path $archive_dir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $output -Recurse -Force -ErrorAction SilentlyContinue

$release_base_url = "https://github.com/webui-dev/webui/releases"
if ($version -eq "nightly")
{
	$url = "$release_base_url/download/$version/$archive"
} else
{
	$url = "$release_base_url/latest/download/$archive"
}
Write-Host "$url"
# Download and extract the archive.
Write-Host "Downloading WebUI@$version..."
Invoke-WebRequest -Uri $url -OutFile $archive

Write-Host "Extracting..."
Expand-Archive -LiteralPath $archive
Move-Item -Path $archive_dir\$archive_dir -Destination $output

# Clean downloaded files and residues.
Remove-Item -Path $archive -Force
Remove-Item -Path $archive_dir -Recurse -Force

Write-Host "Done."
Set-Location $current_location

readonly _MAC_OS_TYPE="macos"
readonly _ARM64_CPU_TYPE="arm64"
readonly _X86_64_CPU_TYPE="x86_64"

err() {
    echo "$1"
    exit 1
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

get_architecture() {
    local _ostype _cputype _bitness _arch _clibtype
    _ostype="$(uname -s)"
    _cputype="$(uname -m)"
    _clibtype="gnu"

    case "$_ostype" in

        Linux)
            _ostype=linux
            ;;

        Darwin)
            _ostype="$_MAC_OS_TYPE"
            ;;
        *)
            err "unsupported OS type: $_ostype"
            ;;

    esac

    case "$_cputype" in
        aarch64 | arm64)
            _cputype="$_ARM64_CPU_TYPE"
            ;;

        x86_64 | x86-64 | x64 | amd64)
            _cputype="$_X86_64_CPU_TYPE"
            ;;
        *)
            err "unsupported CPU type: $_cputype"

    esac

    if [ "$_ostype" = "$_MAC_OS_TYPE" ] && [ "$_cputype" = "$_ARM64_CPU_TYPE" ]; then
      echo "Current machine appears to be Apple Silicon (an arm64 MacOS binary does not yet exist). Downloading the $_X86_64_CPU_TYPE MacOS binary instead..."
      _cputype="$_X86_64_CPU_TYPE"
    fi

    _arch="${_ostype}_${_cputype}"
    RETVAL="$_arch"
}

get_architecture || return 1
ARCH="$RETVAL"

if check_cmd curl; then
    DLDCMD=curl
elif check_cmd wget; then
    DLDCMD=wget
else
    err "must have either curl or wget installed"
fi

DLD_URL="https://github.com/cohere-ai/co/releases/latest/download/co_$ARCH.tar.gz"
DLD_OUTPUT="co-install-temp.tar.gz"

if [ "$DLDCMD" = curl ]; then
    curl --silent --show-error --fail --location $DLD_URL --output $DLD_OUTPUT
elif [ "$_dld" = wget ]; then
    wget $DLD_URL -O $DLD_OUTPUT
fi

tar -xf $DLD_OUTPUT
rm $DLD_OUTPUT

echo "Cohere CLI was downloaded to $PWD/co"
if (which co > /dev/null 2>&1)
then
    echo "It looks like you already have the co CLI installed,
to update, run the following:
    sudo mv $PWD/co $(which co)
"
else
    echo "Copy it somewhere in your PATH eg: 
    mkdir -p /usr/local/bin/ && sudo mv $PWD/co /usr/local/bin/co"
fi

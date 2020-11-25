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
            _ostype=macos
            ;;
        *)
            err "unsupported OS type: $_ostype"
            ;;

    esac

    case "$_cputype" in
        aarch64)
            _cputype=arm64
            ;;

        x86_64 | x86-64 | x64 | amd64)
            _cputype=x86_64
            ;;
        *)
            err "unsupported CPU type: $_cputype"

    esac

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

DLD_URL="https://github.com/cohere-ai/blobheart-cli/releases/latest/download/blobheart-cli_$ARCH.tar.gz"
DLD_OUTPUT="blobheart-install-temp.tar.gz"
INSTALL_PATH="$HOME/.cohere/blobheart"

mkdir -p $HOME/.cohere
echo PATH="$HOME/.cohere/" >> $HOME/.profile

if [ "$DLDCMD" = curl ]; then
    curl --silent --show-error --fail --location $DLD_URL --output $DLD_OUTPUT
elif [ "$_dld" = wget ]; then
    wget $DLD_URL -O $DLD_OUTPUT
fi

tar -xf $DLD_OUTPUT
mv blobheart $INSTALL_PATH
rm $DLD_OUTPUT

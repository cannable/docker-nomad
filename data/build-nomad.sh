#!/bin/bash

# ------------------------------------------------------------------------------
# Install Nomad
# ------------------------------------------------------------------------------

url_prefix="https://releases.hashicorp.com/nomad"
arch=$(uname -i)

dnf install -y \
    bash-completion \
    unzip

case "${arch}" in

    x86_64)
        nomad_arch="amd64"
    ;;

    aarch64)
        nomad_arch="arm64"
    ;;

    *)
        nomad_arch="${arch}"
    ;;
esac



archive="nomad_${NOMAD_VERSION}_linux_${nomad_arch}.zip"
ckfile="nomad_${NOMAD_VERSION}_SHA256SUMS"

url="${url_prefix}/${NOMAD_VERSION}/${archive}"
url_ckfile="${url_prefix}/${NOMAD_VERSION}/${ckfile}"


echo Downloading $archive from $url...
curl -L -o "/tmp/${archive}" "${url}"
curl -L -o "/tmp/${ckfile}" "${url_ckfile}"
curl -L -o "/tmp/${ckfile}.sig" "${url_ckfile}.sig"
curl https://keybase.io/hashicorp/key.asc | gpg --import


# Check the download signature
echo Checking tarball signature...
gpg --verify "/tmp/${ckfile}.sig"

if [[ $? -ne 0 ]]; then
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    (>&2 echo URGENT: $filename DOES NOT MATCH PGP SIGNATURE!)
    (>&2 echo IT WAS DOWNLOADED FROM ${url}.)
    (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
    (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    exit 1
fi


echo Installing nomad...
unzip "/tmp/${archive}" -d /usr/local/bin

# The permissions are probably fine, but let's just be explicit
chown root:root /usr/local/bin/nomad
chmod 0755 /usr/local/bin/nomad

mkdir -p /var/nomad/data
mkdir -p /etc/nomad.d

# Bash completion, because why not?
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad

# Write simple example server config file
cat << 'CFG' > /etc/nomad.d/nomad.hcl
# Full configuration options can be found at https://www.nomadproject.io/docs/configuration

datacenter = "dc01"
data_dir = "/var/nomad/data"
bind_addr = "0.0.0.0"

server {
  enabled = true
  bootstrap_expect = 1
}
CFG


# Cleanup
rm -f "/tmp/${archive}"
rm -f "/tmp/${ckfile}"
rm -f "/tmp/${ckfile}.sig"

dnf clean all

echo Nomad installed.

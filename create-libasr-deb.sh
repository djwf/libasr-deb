#!/bin/sh
set -e

# Set directory variables.
sdir="%%libasr%%"
pdir="%%packages%%"
edir="%%sysconfdir%%/libasr-deb"
tdir="$(mktemp -d --tmpdir=$HOME/tmp)"
idir="$tdir/installdir"

mkdir -p "$pdir"

# Check to see if the most recent libasr commit is new by comparing
# timestamp with previously built packages.
cd "$sdir"
git pull -q
cdate=$(git log -n 1 --date=iso --format=%ci)
version=$(date --date="$cdate" -u +%Y%m%d%H%M%S)"-gitp"
test ! -f "$pdir"/libasr-${version}_amd64.deb

# At this point, the package doesn't exist: announce the package version so
# it shows up at the top of the cron email.
echo -n Building libasr debian package based on git repository
echo with latest commit:
echo
git log -n 1
echo

# Build everything.
./bootstrap
./configure --prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/lib/x86_64-linux-gnu \
	CFLAGS="$(dpkg-buildflags --get CFLAGS)" \
	CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)" \
	CXXFLAGS="$(dpkg-buildflags --get CXXFLAGS)" \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"
make clean
make
mkdir "$idir"
make install DESTDIR="$idir"

# Add README file from the git repository.
mkdir -p "$idir"/usr/share/doc/libasr
cp "$sdir"/README.md "$idir"/usr/share/doc/libasr/
gzip -9 "$idir"/usr/share/doc/libasr/README.md

# Add and rename LICENSE file from the git repository.
cp "$sdir"/LICENSE "$idir"/usr/share/doc/libasr/copyright

# Add a changelog for the snapshot.
cat <<EOF > "$idir"/usr/share/doc/libasr/changelog.Debian
libasr ($version) wheezy; urgency=low

  * new snapshot

 -- An Author  $(date -R)
EOF
gzip -9 "$idir"/usr/share/doc/libasr/changelog.Debian

env EDITOR="sed -i -r -e '/^(Vendor: |License: ).*$/d'" /usr/local/bin/fpm \
		-ef -s dir -t deb -n libasr -v "$version" -C "$idir" \
		-p "$pdir"/libasr-VERSION_ARCH.deb \
		-d "openssl" \
		-d "debconf | debconf-2.0" \
		-m "David J. Weller-Fahy <dave@weller-fahy.com>" \
		--deb-user root \
		--deb-group root \
		--category libs \
		--url https://github.com/OpenSMTPD/libasr \
		--description "libasr is a FREE asynchronous DNS resolver.
This is a snapshot of the libasr git repository master branch: it is not stable
and should not be used unless you want any dependent software to break." \
		.

rm -r "$tdir"

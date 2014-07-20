# libasr-deb

Automatically build a libasr debian package.

## Usage

Install libasr-deb, then clone the libasr git repository.

    git clone git://github.com/libasr/libasr.git libasr

Add a cron job to run create-libasr-deb.sh at your desired interval, here 15
minutes is used.  Note that this can be done as a normal user.

    */15 * * * * /usr/local/bin/create-libasr-deb.sh

## Defaults

Both installation and uninstallation respect DESTDIR.

    libasr official repo:       ~/usr/src/libasr
    Package directory:          ~/usr/debian-packages
    DESTDIR:                    ~

## Installation

    git clone git://github.com/sinecure/libasr-deb.git
    cd libasr-deb
    make install

## Uninstallation

Uninstallation does not touch your repositories (debian packages or libasr) or
your package directory.

    cd libasr-deb
    make uninstall

## Examples

To change the packages placement directory.

    make install PACKAGES=~/packages

## Contribute

* Source code: <https://github.com/sinecure/libasr-deb>
* Issue tracker: <https://github.com/sinecure/libasr-deb/issues>
* Wiki: <https://github.com/sinecure/libasr-deb/wiki>

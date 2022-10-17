# Maintainer: nshan651 <nshan651@aur.archlinux.org>
pkgname=excite-cli
pkgver=v0.2.0_alpha
pkgrel=1
epoch=
pkgdesc="A Terminal-Based Citation Generator"
arch=('x86_64')
url="https://github.com/nshan651/excite-cli"
license=('GPL3')
groups=()
depends=('lua>=5.1')
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("$pkgname-$pkgver.tar.gz"
        "$pkgname-$pkgver.patch")
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
	patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}

build() {
	cd "$pkgname-$pkgver"
	./configure --prefix=/usr
	make
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}

gnutls_dependencies() {
	eval $1="'gmp nettle'"
}

gnutls_fetch() {
	download_and_extract ftp://ftp.gnutls.org/gcrypt/gnutls/v3.4/gnutls-3.4.14.tar.xz $1
}

gnutls_clean() {
	make clean
}

gnutls_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic --disable-doc --disable-tools --with-included-libtasn1 --without-tpm --without-p11-kit --without-idn"
	./configure $config
}

gnutls_make() {
	make
}

gnutls_install() {
	make install
}

gnutls_install_mingw() {
	make install

	sed -i '/Libs.private: / s/$/& -lcrypt32/' $PKG_CONFIG_PATH/gnutls.pc
}

gnutls_enable() {
	:
}

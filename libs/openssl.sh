openssl_dependencies() {
	eval $1="''"
}

openssl_fetch() {
	download_and_extract https://www.openssl.org/source/openssl-1.0.2h.tar.gz $1
}

openssl_clean() {
	make clean
}

openssl_clean_win() {
	nmake -f ms/nt.mak clean
}

openssl_configure() {
	./config shared --prefix=$FF_PREFIX
	make depend
}

openssl_configure_linux32() {
	setarch i386 ./config shared -m32 --prefix=$FF_PREFIX
	make depend
}

openssl_configure_mingw32() {
	CROSS_COMPILE="$TOOL_CHAIN_PREFIX" ./Configure mingw shared --prefix=$FF_PREFIX
	make depend
}

openssl_configure_mingw64() {
	CROSS_COMPILE="$TOOL_CHAIN_PREFIX" ./Configure mingw64 shared --prefix=$FF_PREFIX
	make depend
}

openssl_configure_win32() {
	perl Configure VC-WIN32 --prefix=$FF_PREFIX
}

openssl_configure_win64() {
	perl Configure VC-WIN64A --prefix=$FF_PREFIX
}

openssl_make() {
	make
}

openssl_make_win32() {
	ms/do_nasm.bat
	nmake -f ms/nt.mak
}

openssl_make_win64() {
	ms/do_win64a.bat
	nmake -f ms/nt.mak
}

openssl_install() {
	make install
}

openssl_install_win() {
	nmake -f ms/nt.mak install
}

openssl_enable() {
	:
}

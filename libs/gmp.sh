gmp_dependencies() {
	eval $1="''"
}

gmp_fetch() {
	download_and_extract https://gmplib.org/download/gmp/gmp-6.1.1.tar.xz $1
}

gmp_clean() {
	make clean
}

gmp_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic"
	./configure $config
}

gmp_make() {
	make
}

gmp_install() {
	make install
}

gmp_enable() {
	:
}

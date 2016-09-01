nettle_dependencies() {
	eval $1="''"
}

nettle_fetch() {
	download_and_extract https://ftp.gnu.org/gnu/nettle/nettle-3.2.tar.gz $1
}

nettle_clean() {
	make clean
}

nettle_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic"
	./configure $config
}

nettle_make() {
	make
}

nettle_install() {
	make install
}

nettle_enable() {
	:
}

fdk_aac_dependencies() {
	eval $1="''"
}

fdk_aac_fetch() {
	do_git_checkout "https://github.com/mstorsjo/fdk-aac.git" $1
}

fdk_aac_clean() {
	make clean
}

fdk_aac_clean_win() {
	nmake -f Makefile.vc clean
}

fdk_aac_configure() {
	./autogen.sh

	if [ "$TARGET_OS" = darwin ] ; then
		glibtoolize
	fi

	add_host_and_prefix config "--enable-static --disable-shared"
	./configure $config
}

fdk_aac_configure_win() {
	do_patch fdk_aac-win32-make.patch
}

fdk_aac_make() {
	make
}

fdk_aac_make_win32() {
	nmake -f Makefile.vc machine=Win32
}

fdk_aac_make_win64() {
	nmake -f Makefile.vc machine=Win64
}

fdk_aac_install() {
	make install
}

fdk_aac_install_win() {
	nmake -f Makefile.vc prefix=$FF_PREFIX install
}

fdk_aac_enable() {
	enable_library "nonfree libfdk-aac"
}

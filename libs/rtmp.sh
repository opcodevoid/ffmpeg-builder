rtmp_dependencies() {
	eval $1="'zlib gnutls'"
}

rtmp_dependencies_win() {
	eval $1="'zlib openssl'"
}

rtmp_fetch() {
	do_git_checkout "git://git.ffmpeg.org/rtmpdump" $1
}

rtmp_clean() {
	make clean
}

rtmp_clean_win() {
	nmake -f Makefile.win32 clean
}

rtmp_configure() {
	:
}

rtmp_configure_win() {
	do_patch rtmpdump-win32-make.patch
}

rtmp_make_darwin() {
	make SYS=darwin CRYPTO=GNUTLS SHARED=no prefix=$FF_PREFIX XLDFLAGS="$LDFLAGS" install
}

rtmp_make_linux() {
	make SYS=posix CRYPTO=GNUTLS SHARED=no prefix=$FF_PREFIX XLDFLAGS="$LDFLAGS" install
}

rtmp_make_mingw() {
	make SYS=mingw CRYPTO=GNUTLS SHARED=no CROSS_COMPILE=$TOOL_CHAIN_PREFIX prefix=$FF_PREFIX XLDFLAGS="$LDFLAGS" LIBS_mingw="-lws2_32 -lwinmm -lgdi32 -lcrypt32" install
}

rtmp_make_win() {
	nmake -f Makefile.win32 XCFLAGS="-I$(pwd)" XCFLAGS="-I$FF_INC_DIR" XLDFLAGS="$LDFLAGS"
}

rtmp_install() {
	:
}

rtmp_install_win() {
	nmake -f Makefile.win32 prefix=$FF_PREFIX install
}

rtmp_enable() {
	enable_library "librtmp"
}

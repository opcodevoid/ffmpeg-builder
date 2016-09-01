lame_dependencies() {
	eval $1="''"
}

lame_fetch() {
	download_and_extract http://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz $1

	# Patch the 32-bit build. 
	if [ "$ARCH" = x86 ] ; then
		local last_dir=$(pwd)
		cd lame
		sed -i -e '/xmmintrin\.h/d' configure
		cd $last_dir
	fi
}

lame_clean() {
	make clean
}

lame_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic --disable-frontend --disable-gtktest"
	./configure $config
}

lame_configure_win() {
	:
}

lame_make() {
	make
}

lame_make_win32() {
	sed -i -e "s/ \/opt:NOWIN98//" -e "s/\/GL //" Makefile.MSVC

	nmake -f Makefile.MSVC MSVCVER=Win32 MACHINE=/MACHINE:X86
}

lame_make_win64() {
	sed -i -e "s/ \/opt:NOWIN98//" -e "s/\/GL //" Makefile.MSVC

	nmake -f Makefile.MSVC MSVCVER=Win64 MACHINE=/MACHINE:X64
}

lame_install() {
	make install
}

lame_install_win() {
	mkdir -p $FF_INC_DIR/lame ; cp include/lame.h $FF_INC_DIR/lame
	mkdir -p $FF_LIB_DIR/ ; cp output/libmp3lame-static.lib $FF_LIB_DIR/mp3lame.lib
}

lame_enable() {
	enable_library "libmp3lame"
}

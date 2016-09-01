zlib_dependencies() {
	eval $1="''"
}

zlib_fetch() {
	download_and_extract http://zlib.net/zlib-1.2.8.tar.gz $1
}

zlib_clean() {
	case "$(uname -s)" in
		MINGW*)
			make clean -f win32/Makefile.gcc
			;;
		*)
			make clean
			;;
	esac
}

zlib_clean_win() {
	nmake -f win32/Makefile.msc clean
}

zlib_configure() {
	case "$(uname -s)" in
		MINGW*)
			;;
		*)
			./configure --static --prefix=$FF_PREFIX
			;;
	esac
}

zlib_configure_win() {
	# Use -MT instead of -MD, since this is how FFmpeg is built as well.
	sed -i 's/-nologo -MD/-nologo -MT/' win32/Makefile.msc
	# Remove the inclusion of unistd.h.
	sed -i 's/include <unistd.h>//' zconf.h
}

zlib_make() {
	case "$(uname -s)" in
		MINGW*)
			make -f win32/Makefile.gcc
			;;
		*)
			make CC="$(echo $TOOL_CHAIN_PREFIX)gcc" AR="$(echo $TOOL_CHAIN_PREFIX)ar" RANLIB="$(echo $TOOL_CHAIN_PREFIX)ranlib"
			;;
	esac
}

zlib_make_win32() {
	nmake -f win32/Makefile.msc LOC="-DASMV -DASMINF" OBJA="inffas32.obj match686.obj"
}

zlib_make_win64() {
	nmake -f win32/Makefile.msc AS=ml64 LOC="-DASMV -DASMINF -I." OBJA="inffasx64.obj gvmat64.obj inffas8664.obj"
}

zlib_install() {
	case "$(uname -s)" in
		MINGW*)
			make install -f win32/Makefile.gcc prefix=$FF_PREFIX BINARY_PATH=$FF_BIN_DIR INCLUDE_PATH=$FF_INC_DIR LIBRARY_PATH=$FF_LIB_DIR
			;;
		*)
			make CC="$(echo $TOOL_CHAIN_PREFIX)gcc" AR="$(echo $TOOL_CHAIN_PREFIX)ar" RANLIB="$(echo $TOOL_CHAIN_PREFIX)ranlib" install
			;;
	esac
}

zlib_install_win() {
	mkdir -p $FF_INC_DIR/ ; cp zconf.h zlib.h $FF_INC_DIR/
	mkdir -p $FF_LIB_DIR/ ; cp zlib.lib $FF_LIB_DIR/
	mkdir -p $FF_BIN_DIR/ ; cp zlib1.dll $FF_BIN_DIR/
}

zlib_enable() {
	enable_library "zlib"
}

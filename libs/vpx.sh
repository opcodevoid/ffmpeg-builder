vpx_dependencies() {
	eval $1="''"
}

vpx_fetch() {
	do_git_checkout "https://chromium.googlesource.com/webm/libvpx" $1
}

vpx_clean() {
	make clean
}

vpx_set_params() {
	local __resultvar=$1
	local options=$2

	add_prefix params "--enable-vp8 --enable-vp9 --enable-static --enable-pic --disable-examples --disable-unit-tests --disable-docs $options"

	eval $__resultvar='$params'
}

vpx_configure_darwin() {
	vpx_set_params config "--target=$ARCH-darwin15-gcc"
	./configure $config
}

vpx_configure_linux() {
	vpx_set_params config "--target=$ARCH-linux-gcc"
	./configure $config
}

vpx_configure_mingw32() {
	do_patch vpx-sys-types.patch

	vpx_set_params config "--target=$ARCH-win32-gcc"

	# Need to set CROSS to allow clean stripping with MinGWs tool chain.
	CROSS="$TOOL_CHAIN_PREFIX" ./configure $config
}

vpx_configure_mingw64() {
	do_patch vpx-sys-types.patch

	vpx_set_params config "--target=$ARCH-win64-gcc"

	# Need to set CROSS to allow clean stripping with MinGWs tool chain.
	CROSS="$TOOL_CHAIN_PREFIX" ./configure $config
}

vpx_configure_win32() {
	# Use /MT instead of /MD.
	vpx_set_params config "--target=x86-win32-vs14 --enable-static-msvcrt"
	./configure $config
}

vpx_configure_win64() {
	# Use /MT instead of /MD.
	vpx_set_params config "--target=x86_64-win64-vs14 --enable-static-msvcrt"
	./configure $config
}

vpx_make() {
	make
}

vpx_install() {
	make install
}

vpx_install_win() {
	make install

	local target_dir=

	case $TARGET_OS in
		win32)	target_dir="Win32"	;;
		win64)	target_dir="x64"	;;
		*)		exit				;;
	esac

	mv $FF_LIB_DIR/$target_dir/vpxmt.lib $FF_LIB_DIR/vpx.lib
	rm -R $FF_LIB_DIR/$target_dir
}

vpx_enable() {
	enable_library "libvpx"
}

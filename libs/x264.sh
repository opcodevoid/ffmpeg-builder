x264_dependencies() {
	eval $1="''"
}

x264_fetch() {
	do_git_checkout "git://git.videolan.org/x264.git" $1
}

x264_clean() {
	make clean
}

x264_set_params() {
	local __resultvar=$1
	local options=$2

	add_host_and_prefix params "--enable-static --disable-opencl --disable-cli --enable-pic $options"

	eval $__resultvar='$params'
}

x264_configure() {
	x264_set_params config
	./configure $config
}

x264_configure_mingw() {
	x264_set_params config "--cross-prefix=$TOOL_CHAIN_PREFIX"
	./configure $config
}

x264_configure_win() {
	x264_set_params config "--extra-cflags=-DNO_PREFIX"
	CC=cl ./configure $config
}

x264_make() {
	make
}

x264_install() {
	make install
}

x264_enable() {
	enable_library "libx264"
}

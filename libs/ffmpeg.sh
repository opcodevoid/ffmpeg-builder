ffmpeg_dependencies() {
	eval $1="'$FF_LIBS'"
}

ffmpeg_fetch() {
	#do_git_checkout https://github.com/FFmpeg/FFmpeg.git $1
	download_and_extract http://ffmpeg.org/releases/ffmpeg-3.1.2.tar.bz2 $1
}

ffmpeg_clean() {
	make distclean
}

ffmpeg_set_params() {
	local __resultvar=$1
	local options=$2
	local target_os=$3

	# Make options unique.
	FF_ENABLED_LIBS=$(echo "$FF_ENABLED_LIBS" | tr ' ' '\n' | sort -u)

	add_prefix params "--arch=$ARCH \
		--pkg-config=pkg-config \
		--pkg-config-flags=--static \
		--disable-ffprobe \
		--disable-ffserver \
		--disable-debug \
		--disable-doc \
		--disable-static \
		--enable-shared \
		--enable-gpl \
		--enable-version3 \
		--enable-postproc \
		--enable-runtime-cpudetect \
		--enable-memalign-hack \
		--enable-pic \
		$FF_ENABLED_LIBS \
		$options"

	eval $__resultvar='$params'
}

ffmpeg_set_pthreads() {
	eval $1='"$2 --disable-w32threads --enable-pthreads"'
}

ffmpeg_configure_darwin() {
	ffmpeg_set_params config "--target-os=darwin"
	ffmpeg_set_pthreads config "$config"

	./configure $config
}

ffmpeg_configure_linux32() {
	ffmpeg_set_params config "--target-os=linux --enable-cross-compile --extra-ldflags=-ldl"
	ffmpeg_set_pthreads config "$config"

	./configure $config
}

ffmpeg_configure_linux64() {
	ffmpeg_set_params config "--target-os=linux"
	ffmpeg_set_pthreads config "$config"

	./configure $config
}

ffmpeg_configure_mingw() {
	ffmpeg_set_params config "--target-os=mingw32 --cross-prefix=$TOOL_CHAIN_PREFIX --enable-dxva2"
	ffmpeg_set_pthreads config "$config"

	LDFLAGS="$LDFLAGS -static -static-libgcc -static-libstdc++" ./configure $config
}

ffmpeg_configure_win() {
	ffmpeg_set_params config "--toolchain=$TOOLCHAIN --extra-cflags=$CPPFLAGS --extra-ldflags=$LDFLAGS"

	./configure $config
}

ffmpeg_make() {
	make
}

ffmpeg_install() {
	make install
}

ffmpeg_enable() {
	:
}

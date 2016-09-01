speex_dependencies() {
	eval $1="''"
}

speex_fetch() {
	download_and_extract http://downloads.xiph.org/releases/speex/speex-1.2rc2.tar.gz $1
}

speex_clean() {
	make clean
}

speex_clean_win32() {
	MSBuild.exe "$1/win32/VS2008/libspeex.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32 //target:Clean
}

speex_clean_win64() {
	MSBuild.exe "$1/win32/VS2008/libspeex.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64 //target:Clean
}

speex_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic --enable-sse --disable-binaries"
	./configure $config
}

speex_configure_win() {
	:
}

speex_make() {
	make
}

speex_make_win32() {
	MSBuild.exe "$1/win32/VS2008/libspeex.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32
}

speex_make_win64() {
	MSBuild.exe "$1/win32/VS2008/libspeex.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64
}

speex_install() {
	make install
}

speex_install_win() {
	exit 1
}

speex_enable() {
	enable_library "libspeex"
}

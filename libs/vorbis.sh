vorbis_dependencies() {
	eval $1="'ogg'"
}

vorbis_fetch() {
	download_and_extract http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz $1
}

vorbis_clean() {
	make clean
}

vorbis_clean_win32() {
	MSBuild.exe "win32/VS2010/vorbis_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32 //target:Clean
}

vorbis_clean_win64() {
	MSBuild.exe "win32/VS2010/vorbis_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64 //target:Clean
}

vorbis_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic"
	./configure $config
}

vorbis_configure_win() {
	# Change /MD to /MT
	sed -i 's/MultiThreadedDLL/MultiThreaded/' win32/VS2010/libvorbis/libvorbis_static.vcxproj
}

vorbis_make() {
	make
}

vorbis_make_win32() {
	MSBuild.exe "win32/VS2010/vorbis_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32
}

vorbis_make_win64() {
	MSBuild.exe "win32/VS2010/vorbis_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64
}

vorbis_install() {
	make install
}

vorbis_install_win() {
	local target=

	case $TARGET_OS in
		win32)	target="Win32"	;;
		win64)	target="x64"	;;
		*)		exit			;;
	esac

	mkdir -p $FF_INC_DIR/vorbis ; cp include/vorbis/*.h $FF_INC_DIR/vorbis
	mkdir -p $FF_LIB_DIR/ ; cp win32/VS2010/$target/Release/libvorbis_static.lib $FF_LIB_DIR/vorbis.lib
	cp win32/VS2010/$target/Release/libvorbis_static.lib $FF_LIB_DIR/vorbisenc.lib
	cp win32/VS2010/$target/Release/libvorbisfile_static.lib $FF_LIB_DIR/vorbisfile.lib
}

vorbis_enable() {
	enable_library "libvorbis"
}

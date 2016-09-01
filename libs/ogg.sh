ogg_dependencies() {
	eval $1="''"
}

ogg_fetch() {
	download_and_extract http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz $1
}

ogg_clean() {
	make clean
}

ogg_clean_win32() {
	MSBuild.exe "win32/VS2010/libogg_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32 //target:Clean
}

ogg_clean_win64() {
	MSBuild.exe "win32/VS2010/libogg_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64 //target:Clean
}

ogg_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic"
	./configure $config
}

ogg_configure_win() {
	:
}

ogg_make() {
	make
}

ogg_make_win32() {
	MSBuild.exe "win32/VS2010/libogg_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=Win32
}

ogg_make_win64() {
	MSBuild.exe "win32/VS2010/libogg_static.sln" //p:PlatformToolset=v140 //p:Configuration=Release //p:Platform=x64
}

ogg_install() {
	make install
}

ogg_install_win() {
	local target=

	case $TARGET_OS in
		win32)	target="Win32"	;;
		win64)	target="x64"	;;
		*)		exit			;;
	esac

	mkdir -p $FF_INC_DIR/ogg ; cp include/ogg/*.h $FF_INC_DIR/ogg
	mkdir -p $FF_LIB_DIR/ ; cp win32/VS2010/$target/Release/libogg_static.lib $FF_LIB_DIR/ogg.lib
}

ogg_enable() {
	:
}

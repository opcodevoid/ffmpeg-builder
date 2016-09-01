opus_dependencies() {
	eval $1="''"
}

opus_fetch() {
	download_and_extract http://downloads.xiph.org/releases/opus/opus-1.1.3.tar.gz $1
}

opus_clean() {
	make clean
}

opus_clean_win32() {
	MSBuild.exe "win32/VS2015/opus.sln" //p:Configuration=Release //p:Platform=Win32 //target:Clean
}

opus_clean_win64() {
	MSBuild.exe "win32/VS2015/opus.sln" //p:Configuration=Release //p:Platform=x64 //target:Clean
}

opus_configure() {
	add_host_and_prefix config "--enable-static --disable-shared --enable-pic --disable-doc --disable-extra-programs"
	./configure $config
}

opus_configure_win() {
	# Create version header file.
	IFS='=' read var version <<< $(grep -v '^#' "version.mk")
	echo "#define $var $version" > win32/version.h
}

opus_make() {
	make
}

opus_make_win32() {
	MSBuild.exe "win32/VS2015/opus.sln" //p:Configuration=Release //p:Platform=Win32
}

opus_make_win64() {
	MSBuild.exe "win32/VS2015/opus.sln" //p:Configuration=Release //p:Platform=x64
}

opus_install() {
	make install
}

opus_install_win() {
	local target=

	case $TARGET_OS in
		win32)	target="Win32"	;;
		win64)	target="x64"	;;
		*)		exit			;;
	esac

	mkdir -p $FF_INC_DIR/opus ; cp include/* $FF_INC_DIR/opus
	mkdir -p $FF_LIB_DIR/ ; cp win32/VS2015/$target/Release/*.lib $FF_LIB_DIR/
	mkdir -p $PKG_CONFIG_PATH

	cp opus.pc.in $PKG_CONFIG_PATH/opus.pc

	sed -i -e "s|@prefix@|$FF_PREFIX|" \
		-e "s|@exec_prefix@|\${prefix}|" \
		-e "s|@libdir@|\${exec_prefix}/lib|" \
		-e "s|@includedir@|\${prefix}/include|" \
		-e "s|@PC_BUILD@|floating-point|" \
		-e "s|@VERSION@|1.1.3|" \
		-e "s|@LIBM@|\-lcelt -lsilk_common -lsilk_float|" \
		$PKG_CONFIG_PATH/opus.pc
}

opus_enable() {
	enable_library "libopus"
}

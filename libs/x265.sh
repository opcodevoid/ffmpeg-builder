x265_dependencies() {
	eval $1="''"
}

x265_fetch() {
	download_and_extract https://bitbucket.org/multicoreware/x265/downloads/x265_2.0.tar.gz $1
}

x265_clean() {
	rm -R build/*
}

x265_set_params() {
	eval $1='"-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_IMPLICIT_LINK_LIBRARIES=stdc++"'
}

x265_configure_darwin() {
	x265_set_params config "Darwin"
	exec_in_dir "build" do_cmake "Unix Makefiles" "../source" "Darwin" "$config"
}

x265_configure_linux() {
	x265_set_params config "Linux"
	exec_in_dir "build" do_cmake "Unix Makefiles" "../source" "Linux" "$config"
}

x265_configure_mingw() {
	x265_set_params config

	case "$(uname -s)" in
		MINGW*)
			exec_in_dir "build" do_cmake "MSYS Makefiles" "../source" "Windows" "$config"
			;;
		*)
			exec_in_dir "build" do_cmake "MinGW Makefiles" "../source" "Windows" "-DCMAKE_RANLIB=${TOOL_CHAIN_PREFIX}ranlib -DCMAKE_C_COMPILER=${TOOL_CHAIN_PREFIX}gcc -DCMAKE_CXX_COMPILER=${TOOL_CHAIN_PREFIX}g++ -DCMAKE_RC_COMPILER=${TOOL_CHAIN_PREFIX}windres $config"
			;;
	esac
}

x265_configure_win32() {
	x265_set_params config
	exec_in_dir "build" do_cmake "Visual Studio 14 2015" "../source" "Windows" "-DSTATIC_LINK_CRT=On $config"
}

x265_configure_win64() {
	x265_set_params config
	exec_in_dir "build" do_cmake "Visual Studio 14 2015 Win64" "../source" "Windows" "-DCMAKE_GENERATOR_PLATFORM=x64 -DSTATIC_LINK_CRT=On $config"
}

x265_make() {
	exec_in_dir "build" make
}

x265_make_win() {
	MSBuild.exe "build/x265.sln" //p:Configuration=Release
}

x265_install() {
	exec_in_dir "build" make install
}

x265_install_win() {
	mkdir -p $FF_INC_DIR/ ; cp source/x265.h build/x265_config.h $FF_INC_DIR/
	mkdir -p $FF_BIN_DIR/ ; cp build/Release/libx265.dll build/Release/x265.exe $FF_BIN_DIR/
	mkdir -p $FF_LIB_DIR/ ; cp build/x265.def build/Release/x265-static.lib $FF_LIB_DIR/
	mkdir -p $PKG_CONFIG_PATH ; cp build/x265.pc $PKG_CONFIG_PATH

	sed -i 's/-lx265/-lx265-static/' $PKG_CONFIG_PATH/x265.pc
}

x265_enable() {
	enable_library "libx265"
}

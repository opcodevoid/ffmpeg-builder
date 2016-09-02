#!/bin/bash

FF_TIME=$(date +%s%N)
FF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FF_LIBS_DIR=$FF_DIR/libs
FF_PATCH_DIR=$FF_DIR/patches
FF_PROFILE_DIR=$FF_DIR/profiles
FF_LOG_NAME="build.log"
FF_LOG_PATH=""
FF_PREFIX=""
FF_PROFILE=""
FF_LIBS=""
FF_ENABLED_LIBS=""
FF_BIN_DIR=""
FF_INC_DIR=""
FF_LIB_DIR=""
FF_SRC_DIR=""
FF_FUNCTIONS=( dependencies fetch configure make install enable )


log_enable() {
	exec 3>&1 4>&2 &>> $FF_LOG_PATH
}

log_disable() {
	exec 1>&3 2>&4
}

log_clear() {
	> $FF_LOG_PATH
}

do_notify() {
	local message="$1"

	echo -e "\e[1;34m>>> $message\e[00m"
}

do_notify_error() {
	local message="$1"

	echo -e "\e[1;31m!!! $message\e[00m"
}

error() {
	local message="$1"
	
	log_disable
	do_notify_error "$message"
	log_enable
	
	exit 1
}

add_prefix() {
	local __resultvar=$1
	local options=$2
	local myresult="$options --prefix=$FF_PREFIX"

	eval $__resultvar='$myresult'
}

add_host() {
	local __resultvar=$1
	local options=$2
	local myresult="$options --host=$HOST"

	eval $__resultvar='$myresult'
}

add_host_and_prefix() {
	local __resultvar=$1
	local options=$2
	local myresult="$options --host=$HOST --prefix=$FF_PREFIX"

	eval $__resultvar='$myresult'
}

download_and_extract() {
	local file_url="$1"
	local dest_url="$2"
	local file_name=$(basename "$file_url")
	local src_dir="${file_name%.*}"
	src_dir="${src_dir%.tar}"

	if [ ! -d $dest_url ]; then
		do_notify "Downloading $file_name ..."

		wget -c $file_url		|| return 1

		if [[ -z "$dest_url" ]]; then
			tar xf $file_name	|| return 1
		else
			tar xf $file_name	|| return 1
			mv $src_dir $dest_url
		fi
	
		rm $file_name
	fi
}

do_git_checkout() {
	local repo_url="$1"
	local src_dir="$2"
	local last_dir=$(pwd)

	if [ ! -d $src_dir ]; then
		do_notify "Git clone $repo_url to $src_dir"
    	# Prevent partial checkouts by renaming it only after success.
    	git clone $repo_url $src_dir.tmp	|| return 1
    	mv $src_dir.tmp $src_dir
    	do_notify "Git clone to $src_dir finished."
	else
    	do_notify "Updating $repo_url to latest version..."
		cd $src_dir
		git pull
		cd $last_dir
	fi
}

do_svn_checkout() {
	local repo_url="$1"
	local src_dir="$2"
	local last_dir=$(pwd)

	if [ ! -d $src_dir ]; then
		do_notify "Svn checkout $repo_url to $src_dir"
    	rm -rf $src_dir
    	# Prevent partial checkouts by renaming it only after success.
    	svn co $repo_url $src_dir.tmp	|| return 1
    	mv $src_dir.tmp $src_dir
    	do_notify "Svn checkout to $src_dir finished."
	else
    	do_notify "Updating $repo_url to latest version..."
		cd $src_dir
		svn up
		cd $last_dir
	fi
}

do_patch() {
	local patch_name="$1"

	patch -p0 -N -s --dry-run < $FF_PATCH_DIR/$patch_name 2>/dev/null

	if [ $? -eq 0 ]; then
		do_notify "Patching $(pwd) ..."

		patch -p0 -N < $FF_PATCH_DIR/$patch_name
	fi
}

do_cmake() {
	local generator="$1"
	local dst_dir="$2"
	local system="$3"
	local args="$4"

	cmake -G "$generator" "$dst_dir" \
		-DCMAKE_SYSTEM_NAME="$system" \
		-DCMAKE_INSTALL_PREFIX="$FF_PREFIX" \
		$args
}

exec_in_dir() {
	local dir="$1";	shift
	local last_dir=$(pwd)

	cd $dir
	
	"$@" || return 1
	
	cd $last_dir
}

import_sources() {
	source $FF_PROFILE_DIR/$FF_PROFILE.local

	. $FF_LIBS_DIR/ffmpeg.sh
}

import_installers() {
	if [[ -d $FF_LIBS_DIR ]]; then
		for file in $FF_LIBS_DIR/*; do
			if [[ -f $file ]] && [[ "$file" != *~ ]]; then
				. $file
			fi
		done
	fi
}

contains() {
	declare -a list=("${!1}")

	[[ "${list[@]}" =~ (^|[[:space:]])"$2"($|[[:space:]]) ]]
	return $?
}

function_exists() {
	declare -f -F $1 > /dev/null
	return $?
}

execute_function() {
	local lib_name=$1
	local func_name=$2
	local params=$3
	local t_prefix=${TARGET_OS//[0-9]/}
	local functions=( "$func_name"_"$t_prefix" "$func_name"_"$TARGET_OS" "$func_name" )
	local functions_no_cd=( "$lib_name""_dependencies" "$lib_name""_fetch" "$lib_name""_enable" )
	local last_dir=$(pwd)
	local do_cd=false

	contains functions_no_cd[@] "$func_name" || do_cd=true

	if $do_cd ; then
		cd $lib_name || return 1
	fi
	
	for function in ${functions[@]}; do
		if function_exists "$function"; then
			"$function" "$params"
			
			if (( $? != 0 )); then
				# Exit properly.
				if $do_cd ; then
					cd $last_dir
				fi
				
				return 1
			fi
			
			break
		fi
	done
	
	if $do_cd ; then
		cd $last_dir
	fi
	
	return 0
}

install_library() {
	local name=$1
	local func=

	# Check if all required functions exist.
	for function in ${FF_FUNCTIONS[@]}; do
		func="$name"_"$function"

		if ! function_exists "$func" ; then
			local t_prefix=${TARGET_OS//[0-9]/}
			local sub_functions=( "$func"_"$t_prefix" "$func"_"$TARGET_OS" )
			local found=false

			for sub_function in ${sub_functions[@]}; do
				if function_exists "$sub_function" ; then
					found=true
					break
				fi
			done

			if ! $found ; then
				do_notify_error "Package $name is missing [$function] function. Aborting..."
				exit 1
			fi
		fi
	done

	# Execute package functions.
	execute_function $name "$name"_dependencies deps

	# Resolve all dependencies recursively.
	if [[ ! -z "$deps" ]]; then
		for dep in ${deps[@]}; do
			install_library $dep
		done
	fi

	log_disable
	do_notify "Building $name"
	log_enable
	
	# Critical functions will exit on error.
	
	do_notify "Fetching $name ..."
	execute_function $name "$name"_fetch $name	|| error "Fetching $name failed!"

	do_notify "Cleaning $name ..."
	execute_function $name "$name"_clean

	do_notify "Configuring $name ..."
	execute_function $name "$name"_configure	|| error "Configuring $name failed!"

	do_notify "Making $name ..."
	execute_function $name "$name"_make			|| error "Making $name failed!"

	do_notify "Installing $name ..."
	execute_function $name "$name"_install		|| error "Installing $name failed!"

	execute_function $name "$name"_enable
}

enable_library() {
	local libs=("$@")

	for lib in ${libs[@]}; do
		FF_ENABLED_LIBS="$FF_ENABLED_LIBS --enable-$lib"
	done
}

create_build_dir() {
	mkdir -p $FF_SRC_DIR
	cd $FF_SRC_DIR
}

usage() {
	local profiles=""
	local my_name=$(basename -- "$0")
	my_name="${my_name%.*}"

	# List all available profiles.
	if [[ -d $FF_PROFILE_DIR ]]; then
		for file in $FF_PROFILE_DIR/*; do
			if [[ -f $file ]] && [[ "$file" != *~ ]]; then
				local name=$(basename -- "$file")
				name="${name%.*}"
				profiles="$profiles  $name\n"
			fi
		done
	fi


	cat <<- _EOF_
	Usage: $my_name [options]

	Example: ./$my_name -p mac-x86_64 -i /usr/local/ffmpeg -l "opus lame vorbis vpx x264 x265 rtmp"

	Options:
	  -h,  --help               print this help.
	  -i,  --prefix             installation directory.
	  -p,  --profile            target os profile, see below.
	  -l,  --libs               space separated list of libraries to include into FFmpeg [optional].

	Profiles:
	$(echo -e "$profiles")

	_EOF_
}

check_input() {
	if [ ! -f $FF_PROFILE_DIR/$FF_PROFILE.local ]; then
		usage
		do_notify_error "Profile [$FF_PROFILE] not found."
		exit 1
	fi

	if [ "$FF_PREFIX" = "" ]; then
		usage
		do_notify_error "No prefix specified."
		exit 1
	fi
}

set_vars() {
	FF_BIN_DIR="$FF_PREFIX/bin"
	FF_INC_DIR="$FF_PREFIX/include"
	FF_LIB_DIR="$FF_PREFIX/lib"
	FF_SRC_DIR="$FF_PREFIX/src"
	FF_LOG_PATH="$FF_PREFIX/$FF_LOG_NAME"
}

show_total_time() {
	# Time interval in nanoseconds
	local N=$(($(date +%s%N)-FF_TIME))
	# Seconds
	local S=$((N/1000000000))
	# Milliseconds
	local M=$((N/1000000))

	log_disable
	
	printf "Total time: %02d:%02d:%02d.%03d\n" $((S/3600%24)) $((S/60%60)) $((S%60)) ${M}
}

##### Entry Point

if [ "$#" -lt 2 ]
then
	usage
	exit 1
fi

while [ "$1" != "" ]; do
	case $1 in
		-p | --profile )	shift
							FF_PROFILE=$1
							;;
		-i | --prefix )		shift
							FF_PREFIX=$1
							;;
		-l | --libs )		shift
							FF_LIBS=$1
							;;
		-h | --help )		usage
 							exit
							;;
		* )					usage
							exit 1
	esac
    shift
done

check_input
set_vars
import_sources
import_installers
create_build_dir
log_clear
log_enable
install_library ffmpeg
show_total_time

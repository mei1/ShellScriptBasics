#!/bin/bash

is_tomcat_downloaded_flag=0
is_tomcat_installed_flag=0
is_tomcat_running_flag=0

function get_ts(){
	date +%T
}

function is_tomcat_installed(){
	if [ ! -d /opt/apache-tomcat* ]
	then
		return 0
	else
		return 1
	fi
}

function is_tomcat_downloaded(){
	if [ ! -e apache-tomcat* ]
	then
		return 0
	else
		return 1
	fi
}

function install_tomcat(){
	echo "$(get_ts) : Starting tomcat download"
	wget mirror.intergrid.com.au/apache/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.zip
	echo "$(get_ts) : Unzipping"
	cd /opt/
	sudo unzip -q ~/apache-tomcat*.zip
	echo "$(get_ts) : Tomcat installation is done"
	is_tomcat_installed
	IS_TOMCAT_INSTALLED_FLAG=$?
}

function run_tomcat(){
	cd /opt/apache-tomcat*/bin
	sudo ./startup.sh
}

function check_process(){
	echo "check if $1 is running"
	[[ `pgrep -f $1` ]] && return 1 || return 0
}

function retry(){
	retries=$1
	interval=$2
	cmd="${@: 3}"
	return_code=1
	n=1
	until [ ${n} -gt ${retries} ]
	do
		${cmd} && return_code=$? && break
		n=$[$n+1]
		sleep ${interval}
	done
	return ${return_code}
}

is_tomcat_installed
is_tomcat_installed_flag=$?

if [ "$is_tomcat_installed_flag" -eq 0 ]
then
	echo "tomcat is not installed"
	is_tomcat_downloaded
	is_tomcat_downloaded_flag=$?
else
	echo "tomcat is installed"
	is_tomcat_downloaded_flag=1
fi

echo "tomcat download flag:" $is_tomcat_downloaded_flag

if [ "$is_tomcat_downloaded_flag" -eq 0 ]
then
	echo "tomcat is not downloaded"
	install_tomcat
else
	echo "tomcat is downloaded"
fi

retry 5 5 "check_process tomcat"
is_tomcat_running_flag=$?
echo "is tomcat running:" $is_tomcat_running_flag

if [ "$is_tomcat_running_flag" -eq 0 ]
then
	echo "tomcat is not runnning"
	run_tomcat
else
	echo "tomcat is running"
fi


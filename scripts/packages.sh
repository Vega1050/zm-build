#!/bin/bash
#
# ***** BEGIN LICENSE BLOCK *****
# Zimbra Collaboration Suite Server
# Copyright (C) 2009, 2010, 2011, 2013, 2014, 2015, 2016 Synacor, Inc.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software Foundation,
# version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.
# ***** END LICENSE BLOCK *****

# Script builds all required zimbra packages for the build.
# Usage: bash -x /stash/zm-build/scripts/packages.sh -r 8.8.0.GA -b JUDASPRIEST-880 -n 1672 -o UBUNTU14_64 -t NETWORK -s 20161129140015


#-------------------- Configuration ---------------------------


        SCRIPT_DIR="$(CDPATH= cd "$(dirname "$0")" && pwd)"

	. "$SCRIPT_DIR/config.sh"

	if ( [ -z ${1} ] && [ -z ${2} ] && [ -z ${3} ] && [ -z ${4} ] && [ -z ${5} ] && [ -z ${6} ] ) || ( [ -z ${1} ] || [ -z ${2} ] || [ -z ${3} ] || [ -z ${4} ] || [ -z ${5} ] || [ -z ${6} ] ); then

		echo -e "\tInvalid or insufficient arguments passed in script, it should in form of: bash <full-script-path> <release> <branch> <buildno> <os> <build-type> <build-timestamp>\n"

		exit

	else

		while getopts r:b:n:o:t:s: option
		do
			case "${option}"
			in
				r) release=${OPTARG};;
				b) branch=${OPTARG};;
				n) buildNo=${OPTARG};;
				o) os=${OPTARG};;
				t) buildType=${OPTARG};;
				s) buildTimeStamp=${OPTARG};;
			esac
		done
	fi

	repoDir=${buildsDir}/${os}/${branch}/${buildTimeStamp}_${buildType}
	buildTimeStamp=`echo ${repoDir} | cut -d "/" -f 7 | cut -d "_" -f 1`
	buildLogFile=${repoDir}/logs/build.log

	# Create logs directory
	mkdir -p ${repoDir}/logs

	# Check architecture
	if [[ ${os} = *"UBUNTU"* ]]; then
		arch=amd64
	elif ( [[ ${os} = *"RHEL"* ]] || [[ ${os} = *"CENTOS"* ]] ); then
		arch=x86_64
	else
		echo -e "\tOS doesn't match with build argument OS: ${os} OR wrong arguments passed in build script\n\n\tEXIT\n" >> ${buildLogFile}
		exit
	fi
	mkdir -p ${repoDir}/zm-build/${arch}

	echo -e "Build script arguments: ${1} ${2} ${3} ${4} ${5} ${6}\n" >> ${buildLogFile}

        if [ "$ENV_LOCAL_CP" == "1" ]
        then
            echo -e "Copying git repository manually (temporarily)" >> ${buildLogFile}
            cp -R ${gitRepoDir}/zm-build ${repoDir}
            cp -R ${gitRepoDir}/zm-core-utils ${repoDir}
            cp -R ${gitRepoDir}/zm-licenses ${repoDir}
            cp -R ${gitRepoDir}/zm-aspell ${repoDir}
            cp -R ${gitRepoDir}/zm-postfix ${repoDir}
            cp -R ${gitRepoDir}/zm-amavis ${repoDir}
            cp -R ${gitRepoDir}/zm-dnscache ${repoDir}
            cp -R ${gitRepoDir}/zm-network-build ${repoDir}
            cp -R ${gitRepoDir}/zm-convertd-native ${repoDir}
            cp -R ${gitRepoDir}/zm-convertd-store ${repoDir}
            cp -R ${gitRepoDir}/zm-nginx-conf ${repoDir}
            cp -R ${gitRepoDir}/zm-ldap-utilities ${repoDir}
            cp -R ${gitRepoDir}/zm-convertd-conf ${repoDir}
            cp -R ${gitRepoDir}/zm-hsm ${repoDir}
            cp -R ${gitRepoDir}/zm-archive-utils ${repoDir}
            cp -R ${gitRepoDir}/zm-sync-store ${repoDir}
            cp -R ${gitRepoDir}/zm-sync-tools ${repoDir}
            cp -R ${gitRepoDir}/zm-store-conf ${repoDir}
            cp -R ${gitRepoDir}/zm-web-client ${repoDir}
            cp -R ${gitRepoDir}/zm-windows-comp ${repoDir}
            cp -R ${gitRepoDir}/zm-ews-store ${repoDir}
            cp -R ${gitRepoDir}/zm-openoffice-store ${repoDir}
            cp -R ${gitRepoDir}/zm-network-store ${repoDir}
            cp -R ${gitRepoDir}/zm-versioncheck-utilities ${repoDir}
            cp -R ${gitRepoDir}/zm-admin-console ${repoDir}
            cp -R ${gitRepoDir}/zm-touch-client ${repoDir}
            cp -R ${gitRepoDir}/zm-store ${repoDir}
            cp -R ${gitRepoDir}/zm-help ${repoDir}
            cp -R ${gitRepoDir}/zm-webclient-portal-example ${repoDir}
            cp -R ${gitRepoDir}/zm-downloads ${repoDir}
            cp -R ${gitRepoDir}/zm-zimlets ${repoDir}
            cp -R ${gitRepoDir}/zm-bulkprovision-store ${repoDir}
            cp -R ${gitRepoDir}/zm-certificate-manager-store ${repoDir}
            cp -R ${gitRepoDir}/zm-clientuploader-store ${repoDir}
            cp -R ${gitRepoDir}/zm-license-tools ${repoDir}
            cp -R ${gitRepoDir}/zm-db-conf ${repoDir}
            cp -R ${gitRepoDir}/zm-backup-utilities ${repoDir}
        fi

	echo -e "Exporting script argument values" >> ${buildLogFile}
	export release
	export branch
	export buildNo
	export os
	export buildType
	export repoDir
	export arch
	export buildTimeStamp
	export buildLogFile
	export zimbraThirdPartyServer

#-------------------- Build Packages ---------------------------

	packagesArray=(
              zimbra-snmp
              zimbra-spell
              zimbra-logger
              zimbra-dnscache
              zimbra-apache
              zimbra-mta
              zimbra-proxy
              zimbra-archiving
              zimbra-convertd
              zimbra-store
              zimbra-core
         )

	for i in "${packagesArray[@]}"
	do
            if [ -z "$ENV_ONLY_PACK" ] || [ "$i" == "$ENV_ONLY_PACK" ]
            then
		echo -e "\n\t-> Building ${i} package..." >> ${buildLogFile}
		chmod +x "$SCRIPT_DIR/packages"/${i}.sh
		"$SCRIPT_DIR/packages"/${i}.sh
            fi
	done
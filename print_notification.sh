#!/bin/bash
# Copyright (C) 2017 Vincent Zvikaramba
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
BUILD_START_TIME=
function print_start_build {
	if [ "x${JOB_BUILD_NUMBER}" != "x" ] && [ ${JOB_BUILD_NUMBER} -ge 1 ]; then
		logb "\n==========================================================="
		logb "Building: $JOB_DESCRIPTION\n"
		logb "Build target: $BUILD_TARGET\n"
		logb "Release type: ${release_type} \n"
		logb "Start time: ${dateStr}\n"
		logb "Build host: ${USER}@${HOSTNAME}\n"
		arc_name=${DISTRIBUTION}-${ver}_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)_${release_type}-${DEVICE_NAME}
		logb "Archive prefix is: ${arc_name} \n"
		logb "Output Directory: ${OUTPUT_DIR}\n"
		logb "============================================================\n"

		if [ "x$SILENT" != "x1" ]; then
			dateStr=`TZ='UTC' date`

			BUILD_START_TIME=$(date +%s)

			if [ "x$JOB_DESCRIPTION" != "x" ]; then
				textStr="${JOB_DESCRIPTION}, build %23${JOB_BUILD_NUMBER} started."
				textStr+="%0A%0AThe device's codename is ${DEVICE_NAME}."
			else
				textStr="Building: ${distroTxt} ${ver} for the ${DEVICE_NAME}"
				textStr+="%0A%0ABuild target: $BUILD_TARGET"
			fi

			textStr+="%0A%0AThis build is running on ${USER}@${HOSTNAME}"
			textStr+="%0A%0AStart time: ${dateStr}"

			if [ "x${JOB_URL}" != "x" ]; then
				textStr+="%0A%0AYou can monitor this build's progress at:"
				textStr+="%0A${JOB_URL}/console"
			fi

			if [ "x$PRINT_VIA_PROXY" != "x" ] && [ "x$SYNC_HOST" != "x" ]; then
				timeout -s 9 20 ssh $SYNC_HOST wget \'"https://api.telegram.org/bot${BUILD_TELEGRAM_TOKEN}/sendMessage?chat_id=${BUILD_TELEGRAM_CHATID}&text=$textStr"\' -O - > /dev/null 2>/dev/null
			else

				timeout -s 9 10 wget "https://api.telegram.org/bot${BUILD_TELEGRAM_TOKEN}/sendMessage?chat_id=${BUILD_TELEGRAM_CHATID}&text=$textStr" -O - > /dev/null 2>/dev/null
			fi
		fi
	fi
}

function print_end_build {
	logb "Done."
	if [ "x$SILENT" != "x1" ]; then
		target_str_len=$(echo /var/lib/jenkins/jobs | wc -c)
		r_dir=$(echo $OUTPUT_DIR | cut -c ${target_str_len}-)
		link="https://artifacts.msm8916.com${r_dir}"

		END_TIME=$( date +%s )
		buildTime="%0A%0ABuild time: $(format_time ${END_TIME} ${BUILD_START_TIME})"
		totalTime="%0ATotal time: $(format_time ${END_TIME} ${START_TIME})"


		if [ "x$BUILD_URL" != "x" ]; then
			arc_name=${DISTRIBUTION}-${ver}_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)_${release_type}-${DEVICE_NAME}
			rec_name=${recovery_flavour}-${DISTRIBUTION}-${ver}_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)_${DEVICE_NAME}
			#bimg_name=bootimage-${DISTRIBUTION}-${ver}_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)_${DEVICE_NAME}
			bimg_name=boot_caf-based_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)-${DEVICE_NAME}
			boot_tar_name=bootimage_j${JOB_BUILD_NUMBER}_$(date +%Y%m%d)-${DEVICE_NAME}.tar

			if [ "$BUILD_TARGET" == "recoveryimage" ]; then
				str_rec="%0A%0ARecovery: ${link}/builds/${rec_name}.tar"
			elif [ "$BUILD_TARGET" == "bootimage" ]; then
				str_boot1="%0A%0ABoot zip package: ${link}/builds/${bimg_name}.zip"
				str_boot2="%0A%0ABoot (ODIN package): ${link}/builds/${boot_tar_name}"
				str_boot=${str_boot1}${str_boot2}
			elif [ "$BUILD_TARGET" == "otapackage" ]; then
				str_rom="%0A%0A ROM: ${link}/builds/${arc_name}.zip"
				str_rec="%0A%0A Recovery: ${link}/builds/${rec_name}.tar"
			fi
			str_changelog="%0A%0AChangelog: ${link}/builds/changelog-${arc_name}.txt"
			str_blurb="%0A%0AYou can flash boot/recovery images using ODIN or you can extract them using 7zip on Windows or tar under Linux and flash using TWRP."
		fi

		if [ "x$JOB_DESCRIPTION" != "x" ]; then
			str_main="$JOB_DESCRIPTION, build %23${JOB_BUILD_NUMBER}"
		else
			str_main="${distroTxt} ${ver} ${BUILD_TARGET} for the ${DEVICE_NAME}"
		fi

		str_main+=" completed successfully."

		textStr="${str_main}${str_rom}${str_rec}${str_boot}${str_changelog}${str_blurb}${buildTime}${totalTime}"

		textStr=$(echo $textStr |sed s'/\/\//\//'g)
		textStr=$(echo $textStr |sed s'/http:\//http:\/\//'g)
		textStr=$(echo $textStr |sed s'/https:\//https:\/\//'g)

		if [ "x$PRINT_VIA_PROXY" != "x" ] && [ "x$SYNC_HOST" != "x" ]; then
			timeout -s 9 20 ssh $SYNC_HOST wget \'"https://api.telegram.org/bot${BUILD_TELEGRAM_TOKEN}/sendMessage?chat_id=${BUILD_TELEGRAM_CHATID}&text=$textStr"\' -O - > /dev/null 2>/dev/null
		else
			timeout -s 9 10 wget "https://api.telegram.org/bot${BUILD_TELEGRAM_TOKEN}/sendMessage?chat_id=${BUILD_TELEGRAM_CHATID}&text=$textStr" -O - > /dev/null 2>/dev/null
		fi
	fi
}

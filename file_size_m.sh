#!/bin/bash

##
##  Copyright (C) 2020 Shintaro Fujiwara
##
##  This script is free software; you can redistribute it and/or
##  modify it under the terms of the GNU Lesser General Public
##  License as published by the Free Software Foundation; either
##  version 2.1 of the License, or (at your option) any later version.
##
##  This script is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##  Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public
##  License along with this library; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
##  02110-1301 USA
##
## This script originates 'https://github.com/intrajp/intraNetit'.
##
## This script outputs file type size in certain directory.
## Create directory in certain path 
## Copy this file into it.
## Execute this script.
## Result file is  ./output_intrajp/data_file_size_final
##
## Version: v1.2.3m
## Written by Shintaro Fujiwara
#################################

FILE_TEMP1="intrajp_tmp1"
FILE_TEMP11="intrajp_tmp11"
FILE_TEMP12="intrajp_tmp12"
FILE_TEMP21="intrajp_tmp21"
FILE_TEMP22="intrajp_tmp22"
FILE_TEMP51="intrajp_tmp51"
FILE_TEMP52="intrajp_tmp52"
FILE_TEMP53="intrajp_tmp53"
SIZE_TYPE_FILE="intrajp_size_type"
TYPE_FILE="intrajp_type"
SIZE_CALCULATED_FILE="intrajp_size_calculated"

OUTPUTDIR="output_intrajp"

FILE_COMPLETE_FINAL="${OUTPUTDIR}/data_file_size_final"

function create_size_type_file()
{
    LANG=C; find "${1}" -type f -exec file {} \; | awk -F";" '{ print $1 }' | sort > "${FILE_TEMP1}"
    LANG=C; find "${1}" -type f -exec du -a {} + | sort -k2 | less > "${FILE_TEMP11}"
    awk -F" " '{ print $2": "$1":" }' "${FILE_TEMP11}" > "${FILE_TEMP12}"
    join "${FILE_TEMP12}" "${FILE_TEMP1}" > "${FILE_TEMP21}"
    awk -F":" '{ print $2" "$1";"$3 }' "${FILE_TEMP21}" | sort -k3 > "${FILE_TEMP22}"
    awk -F";" '{ print $1 }' "${FILE_TEMP22}" > "${FILE_TEMP51}"
    awk -F";" '{ print $2 }' "${FILE_TEMP22}" > "${FILE_TEMP52}"
    awk -F"," '{ print ";"$1 }' "${FILE_TEMP52}" > "${FILE_TEMP53}"
    paste "${FILE_TEMP51}" "${FILE_TEMP53}" > "${SIZE_TYPE_FILE}"
    sed -i -e 's/^[[:space:]]//g' "${SIZE_TYPE_FILE}"
}

function create_output_file()
{
    local size_total=0
    local directory_given="${1}"
    awk -F"; " '{ print $2 }' "${SIZE_TYPE_FILE}" | uniq > "${TYPE_FILE}"
    while read line
    do
        size_sum=$(grep "${line}" "${SIZE_TYPE_FILE}" | awk '{ sum += $1 } END { print sum }')
        size_total=$((size_total + size_sum))
        echo "${size_sum} ${line}"
    done < "${TYPE_FILE}" >> "${SIZE_CALCULATED_FILE}"
    echo "Showing file size as KBytes in ${directory_given}" > "${FILE_COMPLETE_FINAL}"
    echo "${size_total} Total" >> "${FILE_COMPLETE_FINAL}"
    sort -n -k1gr "${SIZE_CALCULATED_FILE}" >> "${FILE_COMPLETE_FINAL}"
    echo $(date) >> "${FILE_COMPLETE_FINAL}"
}

# This function is the main function of this script
# $1: root directory which is to be calculated which should be full path
# $2: working directory in which 'output_intrajp' directory is created
# $3: sub directory which is actually calculated 
function do_calculate_size ()
{
    local directory_given=""
    ## entry point ##
    if [ ! -z "${1}" ]; then
        directory_given="${1}"
        if [ ! -z "${3}" ]; then
            directory_given="${directory_given}/${3}"
            if [ ! -d "${directory_given}" ]; then
                echo "Directory ${directory_given} does not exist"
                exit 1
            else
                echo "Directory ${directory_given} exists"
                case "${directory_given}" in
                    /*) echo "absolute path" ;;
                    *) echo "Please give absolute path to first variable"
                        exit 1 
                esac
            fi
        else
            exit 1
        fi
    else
        exit 1
    fi
    if [ ! -z "${2}" ]; then
        WORK_DIR="${2}"
    else
        exit 1
    fi
    pushd "${WORK_DIR}" 

    create_size_type_file "${directory_given}"
    create_output_file "${directory_given}"

    unlink "${FILE_TEMP1}"
    unlink "${FILE_TEMP11}"
    unlink "${FILE_TEMP12}"
    unlink "${FILE_TEMP21}"
    unlink "${FILE_TEMP22}"
    unlink "${FILE_TEMP51}"
    unlink "${FILE_TEMP52}"
    unlink "${FILE_TEMP53}"
    unlink "${SIZE_TYPE_FILE}"
    unlink "${TYPE_FILE}"
    unlink "${SIZE_CALCULATED_FILE}"

    unlink "${OUTPUTDIR}/${3}"
    mv "${FILE_COMPLETE_FINAL}" "${OUTPUTDIR}/${3}"

    popd
}

if [ -z "${1}" ]; then
    exit 1
fi
if [ -z "${2}" ]; then
    exit 1
fi

if [ ! -d "${2}/${OUTPUTDIR}" ]; then
    mkdir "${2}/${OUTPUTDIR}" 
else
    #we want to remove old files
    rm -f "${2}/${OUTPUTDIR}/*"
fi

do_calculate_size "${1}" "${2}" "cache"
do_calculate_size "${1}" "${2}" "filedir"
do_calculate_size "${1}" "${2}" "lang"
do_calculate_size "${1}" "${2}" "localcache"
do_calculate_size "${1}" "${2}" "models"
do_calculate_size "${1}" "${2}" "muc"
do_calculate_size "${1}" "${2}" "sessions"
do_calculate_size "${1}" "${2}" "temp"
do_calculate_size "${1}" "${2}" "trashdir"

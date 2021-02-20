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
## Version: v1.0.0m
## Written by Shintaro Fujiwara
#################################

FILE_TEMP1="intrajp_tmp1"
FILE_TEMP2="intrajp_tmp2"
FILE_TEMP11="intrajp_tmp11"
FILE_TEMP12="intrajp_tmp12"
FILE_TEMP21="intrajp_tmp21"
FILE_TEMP22="intrajp_tmp22"
FILE_TEMP23="intrajp_tmp23"
FILE_TEMP24="intrajp_tmp24"
FILE_TEMP31="intrajp_tmp31"

OUTPUTDIR="output_intrajp"

FILE_COMPLETE_FINAL="${OUTPUTDIR}/data_file_size_final"

function test0()
{
    { LANG=C; find "${1}" -type f -exec file {} \; ; } > "${FILE_TEMP1}" ; awk -F";" '{ print $1 }' "${FILE_TEMP1}" | sort > "${FILE_TEMP2}" 
    LANG=C; find "${1}" -type f -exec du -a {} + | sort -k2 | less > "${FILE_TEMP11}" ; awk -F" " '{ print $2": "$1":" }' "${FILE_TEMP11}" > "${FILE_TEMP12}"
    join "${FILE_TEMP12}" "${FILE_TEMP2}" > "${FILE_TEMP21}"
    awk -F":" '{ print $2" "$1";"$3 }' "${FILE_TEMP21}" > "${FILE_TEMP22}" ; sort -k3 "${FILE_TEMP22}" > "${FILE_TEMP23}"
    awk -F"," '{ print $1 }' "${FILE_TEMP23}" > "${FILE_TEMP24}"
}

function test1()
{
    last_line=$(wc -l < "${FILE_TEMP24}")
}

function test2()
{
    local size_file_type=0
    local size_all=0
    local file_type_pre=""
    local line_num=0
    local type_changed="no"

    while read line
    do
        size_this=0
        file_type_this=""

        size_this=$(echo "${line}" | awk -F" " '{ print $1 }')
        file_type_this=$(echo "${line}" | awk -F";" '{ print $2 }')

        ## type had changed, so the sum of size should be echoed
        if [ ! "${file_type_pre}" == "${file_type_this}" ] && [ "${line_num}" -ne 0 ] ; then
            echo "${size_file_type}"" ""${file_type_pre}"
            size_file_type=0
        fi
        size_file_type=$((size_file_type + size_this))
        file_type_pre="${file_type_this}"
        line_num=$((line_num + 1))

        ## file has only two types or under
        if [ "${line_num}" == "${last_line}" ] && ( [ "${file_type_pre}" != "${file_type}" ] || [ "${file_type_pre}" != "${file_type}" ] ); then
            echo "${size_file_type}"" ""${file_type_this}"
        fi
        size_all=$((size_all + size_this))

        ## last line we echo total size
        if [ "${line_num}" == "${last_line}" ]; then
            echo "${size_all}"" ""Total"
        fi
    done < "${FILE_TEMP24}" > "${FILE_TEMP31}" 
}

function test3()
{
    echo "Showing file size as kbytes in ${DIRECTORY_GIVEN}" > "${FILE_COMPLETE_FINAL}"
    sort -n -r -k1 "${FILE_TEMP31}" >> "${FILE_COMPLETE_FINAL}"
    echo $(date) >> "${FILE_COMPLETE_FINAL}"
}

# This function is the main function of this script
# $1: root directory which is to be calculated which should be full path
# $2: working directory in which 'output_intrajp' directory is created
# $3: sub directory which is actually calculated 
function do_calculate_size ()
{
    ## entry point ##
    if [ ! -z "${1}" ]; then
        DIRECTORY_GIVEN="${1}"
        if [ ! -z "${3}" ]; then
            DIRECTORY_GIVEN="${DIRECTORY_GIVEN}/${3}"
            if [ ! -d "${DIRECTORY_GIVEN}" ]; then
                echo "Directory ${DIRECTORY_GIVEN} does not exist"
                exit 1
            else
                echo "Directory ${DIRECTORY_GIVEN} exists"
                case "${DIRECTORY_GIVEN}" in
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

    test0 "${DIRECTORY_GIVEN}"
    test1
    test2
    test3

    unlink "${FILE_TEMP1}"
    unlink "${FILE_TEMP2}"
    unlink "${FILE_TEMP11}"
    unlink "${FILE_TEMP12}"
    unlink "${FILE_TEMP21}"
    unlink "${FILE_TEMP22}"
    unlink "${FILE_TEMP23}"
    unlink "${FILE_TEMP24}"
    unlink "${FILE_TEMP31}"

    mv "${OUTPUTDIR}/data_file_size_final" "${OUTPUTDIR}/${3}"

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

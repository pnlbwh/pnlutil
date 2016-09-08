#!/bin/bash -eu

# Author: Chuck Theobald, March 2012
# This script depends upon DCMTK's dcmdump program.
# It will copy a directory full of DICOM files into the
# given output directory with a sub-directory named for
# the ProtocolName group,element.  Alternative sortings
# may be had by judicious editing and modification of this
# script.

function usage {
  echo "Usage: ${0##*/} -i <DICOM directory>"
  echo "          -o Output directory"
  #echo "          -m Move instead of copy"
  echo "          -h This page"
}

cmd=""
while getopts "hi:o:m" flag
do
  case "$flag" in
    i)
      DICOMDIR=$OPTARG
      ;;
    o)
      OUTDIR=$OPTARG
      ;;
    m)
      cmd="mv"
      ;;
    h|?)
      usage
      exit 2
      ;;
  esac
done

if [ -z "${DICOMDIR-}" ]; then
  echo "DICOMDIR is required"
  usage
  exit 2
fi

if [ -z "${OUTDIR-}" ]; then
  echo "OUTDIR is required"
  usage
  exit 3
else
  mkdir -p ${OUTDIR}
fi

tmp=$(mktemp)
dirTmp=$(mktemp -d)

# Recurse input dicom directory and copy each dicom to a temporary directory for processing. Dicoms are named
# as their md5 hash
find $DICOMDIR -type f | while read file ; do cp "$file" $dirTmp/"$(md5sum $file | awk '{ print $1 }' )" ; done
# Select each file in given DICOM directory.
for d in ${dirTmp}/*
do
  echo -n .

  dcmdump --scan-directories ${d} > $tmp

  PID=$(cat $tmp | grep -e '^(0010,0020)' | sed -e 's/^(0010,0020).*\[\(.*\)\].*/\1/')
  StudyTime=$(cat $tmp | grep -e '^(0008,0030)' | sed -e 's/^(0008,0030).*\[\(.*\)\].*/\1/')
  StudyDate=$(cat $tmp | grep -e '^(0008,0020)' | sed -e 's/^(0008,0020).*\[\(.*\)\].*/\1/')
  ProtocolName=$(cat $tmp | grep -e '^(0018,1030)' | sed -e 's/^(0018,1030).*\[\(.*\)\].*/\1/')
  NUMBER=$(echo $StudyTime | awk '{ print $0 / 100 }')
  NUMBER=$(echo $NUMBER | awk -F. '{ print $1 }')
  NUMBER=$(printf "%04.0f" $NUMBER)
  PP=$(echo $ProtocolName | awk '{ gsub(" ","_"); print }')
  PP=$(echo $PP | awk '{ gsub("/","_"); print }')
  PP=$(echo $PP | awk '{ gsub("/","_"); print }')
  StudyDesc=$(cat $tmp | grep -e '^(0008,1030)' | sed -e 's/^(0008,1030).*\[\(.*\)\].*/\1/')
  StudyDesc=$(echo $StudyDesc | awk '{ gsub(" ","_"); print }')

  SeriesDesc=$(cat $tmp | grep -e '^(0008,103e)' | sed -e 's/^(0008,103e).*\[\(.*\)\].*/\1/')
  SeriesDesc=$(echo $SeriesDesc | awk '{ gsub(" ","_"); print }')
  SeriesDesc=$(echo $SeriesDesc | awk '{ gsub("\\(0008,103e\\)_LO_\\(no_value_available\\)","NoSeDesc"); print }')
  SeriesDesc=$(echo $SeriesDesc | awk '{ gsub("\\(no_value_available\\)","NoSeDesc"); print }')
  SeriesDesc=$(echo $SeriesDesc | awk '{ gsub("_#_0,_0_SeriesDescription",""); print }')
  SeriesDesc=$(echo $SeriesDesc | awk '{ gsub("/",""); print }')

  SID=$(cat $tmp | grep -e '^(0020,000d)' | sed -e 's/^(0020,000d).*\[\(.*\)\].*/\1/')
#  echo $SeriesDesc
  SeriesNumber=$(cat $tmp | grep -e '^(0020,0011)' | sed -e 's/^(0020,0011).*\[\(.*\)\].*/\1/')
#  echo $SeriesNumber
  Modality=$(cat $tmp | grep -e '^(0008,0060)' | sed -e 's/^(0008,0060).*\[\(.*\)\].*/\1/')
# (0020,000d)
#  UUID=$(cat $tmp | grep -e '^(0008,0018)' | sed -e 's/^(0008,0018).*\[\(.*\)\].*/\1/')
  UUID=$(cat $tmp | grep -e '^(0020,000e)' | sed -e 's/^(0020,000e).*\[\(.*\)\].*/\1/')
  # UUID=$(cat 3008.txt | grep -e '^(0008,0018)' | sed -e 's/^(0008,0018).*\[\(.*\)\].*/\1/')
  UUID=$(echo $UUID | sed -e 's/\(.*\)\.\(.*\)$/\1/')
  UUID=$(echo $UUID | sed -e 's/\(.*\)\.\(.*\)$/\1/')
  UUID=$(echo $UUID | sed -e 's/\(.*\)\.\(.*\)$/\1/')
  INSTANCE=$(cat $tmp | grep -e '^(0020,0013)' | sed -e 's/^(0020,0013).*\[\(.*\)\].*/\1/')
  FNAME=$(printf "Image%04d.dcm" "$INSTANCE")
# 
  rm $tmp

#  PNAME="${PID}_${StudyDate}_${NUMBER}_${Modality}_${UUID}_${SeriesDesc}"
  PNAME="${PID}_${StudyDate}_${UUID}_${SeriesNumber}_${SeriesDesc}"
  DESTDIR=${OUTDIR}/${PNAME}
  if [ ! -d ${DESTDIR} ]; then
      mkdir ${DESTDIR}
  fi
  mv ${d} ${DESTDIR}/${FNAME}
done

rm -rf "$dirTmp"

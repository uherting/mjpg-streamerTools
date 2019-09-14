#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <compile> | <exec>"
  exit 99
fi

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

PARM=$1


REP_NAME="mjpg-streamer"
GH_REPOSITORY="https://github.com/uherting/${REP_NAME}.git"
EXPERIMENTAL_DIR="mjpg-streamer/mjpg-streamer-experimental"
BUILD_DIR="${EXPERIMENTAL_DIR}/_build"

#echo "BNAME=${BNAME}"
#echo "DNAME=${DNAME}"
#echo "GH_REPOSITORY=${GH_REPOSITORY}"

# go to the directory where the script resides
cd ${DNAME}/..

# compile from scratch
if [ "${PARM}" == "compile" ]; then
  if [ -d ${REP_NAME} ]; then
    rm -rf ${REP_NAME}
    echo "deleted existing dir ${REP_NAME}"
  fi

  # fetch repository:
  git clone ${GH_REPOSITORY}
  if [ $? -ne 0 ]; then
    echo "ERROR: git clone ${GH_REPOSITORY}"
    exit 1
  fi

  # just a test ...
  cd ${EXPERIMENTAL_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${EXPERIMENTAL_DIR} not possible"
    exit 2
  fi
  cd -

  mkdir -p ${BUILD_DIR}
  cd ${BUILD_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${BUILD_DIR} not possible"
    exit 2
  fi

  cmake -DENABLE_HTTP_MANAGEMENT=ON ..
  if [ $? -ne 0 ]; then
    echo "ERROR: cmake ended with errors"
    exit 3
  fi

  make
  if [ $? -ne 0 ]; then
    echo "ERROR: make ended with errors"
    exit 4
  fi
fi

# execution:
if [ "${PARM}" == "exec" ]; then
  cd ${BUILD_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${BUILD_DIR} not possible"
    exit 2
  fi
pwd
  LD_LIBRARY_PATH=""
  for file in output_http.so input_raspicam.so
  do
    FN="`find . -name ${file}`"
    DN="`dirname ${FN}`"
    if [ "${LD_LIBRARY_PATH}" == "" ]; then
      LD_LIBRARY_PATH="${DN}"
    else
      LD_LIBRARY_PATH="${LD_LIBRARY_PATH};${DN}"
    fi
  done

  export LD_LIBRARY_PATH
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

  #./mjpg_streamer -o "output_http.so -w ./www" -i "input_raspicam.so -fps 5"
  ./mjpg_streamer -o "output_http.so -w ./www" -i "input_raspicam.so -fps 20"
fi


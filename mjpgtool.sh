#!/bin/bash


# This script is for compilation and testing only. It is not to be used
# as a replacement of the scripts webcam and WebcamDeamon.

#
# This script can with the parameter #1
# a) = "compile"
#    - fetch the mjpg-streamer-experimental repository and compiles it
# b) = "exec"
#    - start a test execution on mjpg-streamer executable with parameters
#      for the connected Raspberry Pi camera with certain parameters
#


if [ $# -ne 1 ]; then
  echo "Usage: $0 <compile> | <exec>"
  exit 99
fi

PARM=$1

BNAME=`basename $0 .sh`
DNAME=`dirname $0`

# read central config file
. ${DNAME}/tools.conf

if [ ! -d ${BASE_GITHUB_ROOT} ]; then
  echo "BASE_GITHUB_ROOT dir does not exist: ${BASE_GITHUB_ROOT}"
  exit 1
fi
if [ ! -d ${GITHUB_ROOT} ]; then
  echo "GITHUB_ROOT dir does not exist: ${GITHUB_ROOT}"
  exit 1
fi

# go to the directory where all GitHub repositories are stored
cd ${GITHUB_ROOT}

# compile from scratch
if [ "${PARM}" == "compile" ]; then
  if [ -d ${GITHUB_REPOSITORY_NAME} ]; then
    rm -rf ${GITHUB_REPOSITORY_NAME}
    echo "deleted existing dir ${GITHUB_REPOSITORY_NAME}"
  fi

  # fetch repository:
  git clone ${GITHUB_REPOSITORY}
  if [ $? -ne 0 ]; then
    echo "ERROR: git clone not possible on repository ${GITHUB_REPOSITORY}"
    exit 1
  fi

  # prepare the compilation (the dir should exist)
  pushd ${EXPERIMENTAL_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${EXPERIMENTAL_DIR} not possible"
    exit 2
  fi
  popd

  # create the dir where compilation takes place
  mkdir -p ${BUILD_DIR}
  cd ${BUILD_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${BUILD_DIR} not possible"
    exit 2
  fi

  # create Makefile(s) with enabled www option
  cmake -DENABLE_HTTP_MANAGEMENT=ON ..
  if [ $? -ne 0 ]; then
    echo "ERROR: cmake ended with errors"
    exit 3
  fi

  # compile the program / the libraries
  make
  if [ $? -ne 0 ]; then
    echo "ERROR: make ended with errors"
    exit 4
  fi
fi

# execution:
if [ "${PARM}" == "exec" ]; then
  pushd ${BUILD_DIR}
  if [ $? -ne 0 ]; then
    echo "ERROR: cd to ${BUILD_DIR} not possible"
    exit 2
  fi

  # export the path where the input and output libraries are located
  export_ld_library_path "input_raspicam.so output_http.so"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

  # start the test by executing the program with parameters
  #${NAME_OF_THE_EXECUTABLE} -o "output_http.so -w ./www" -i "input_raspicam.so -fps 5"
  #${NAME_OF_THE_EXECUTABLE} -o "output_http.so -w ./www" -i "input_raspicam.so -fps 20"

  popd
fi


#!/bin/bash
##############################################################################
#
# Copyright (c) 2024 JDiepolder
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
##############################################################################
# NOTE
##############################################################################
#
# THE MIT LICENSE ABOVE APPLIES EXCLUSIVELY TO THIS SCRIPT AND DOES NOT EXTEND 
# TO ANY THIRD-PARTY SOFTWARE PACKAGES THAT MAY BE DOWNLOADED, COPIED, OR 
# INSTALLED BY THIS SCRIPT.
#
# USERS ARE RESPONSIBLE FOR REVIEWING AND COMPLYING WITH THE LICENSE TERMS OF 
# THE SOFTWARE PACKAGES REFERENCED OR INSTALLED BY THIS SCRIPT.
#
##############################################################################
# README
##############################################################################
#
# This script serves as a template for setting up the environment with various 
# software components in Ubuntu-focal. 
#
# It is intended to be modified according to your specific needs.
#
# THOROUGLY TEST THE SCRIPT IN A CONTROLLED ENVIRONMENT BEFORE ANY USE!
#
# Below is a brief overview of key components and configurations:
#
# - Phoenix-Environment Bundle: Includes the pxpy whl-package, the
#   phoenix vsix-package, and the phoenix deb-package.
#
# - Phoenix-OC: Includes the pxoc whl-package.
#
# - IPOPT Compilation: IPOPT, a nonlinear programming solver, is compiled 
#   from source. The user can specify an HSL (Harwell Subroutine Library) archive
#   for advanced linear solvers; otherwise, the Mumps linear solver is used
#   by default. If desired, place the HSL archive in the same directory as this 
#   script and adjust the HSL_TAR_GZ_ARCHIVE variable below accordingly.
#
# - Slurm Setup: The script configures Slurm, a workload manager, in a minimal
#   setup (single node configuration). This setup is intended as a placeholder 
#   and should be expanded based on the actual infrastructure of the user.
#
# - Phoenix Installation: The default installation prefix for Phoenix software
#   components is set to /opt/apps/. These installations utilize environment 
#   modules to dynamically manage and load dependencies.
#
# - OpenMPI: Since OpenMPI is installed via the Debian package manager and is
#   available system-wide, a placeholder module file is created to integrate with
#   the environment modules system, ensuring consistency in a single-node setup.
#
# - Environment Modules: The environment module files are linked for convenience. 
#
##############################################################################
# Settings
##############################################################################
# HSL Archive Configuration for IPOPT
# - If HSL_TAR_GZ_ARCHIVE="none", the default linear solver Mumps will be used.
# - Otherwise, place the HSL archive in the same directory as this script, and 
#   set the variable accordingly, e.g., HSL_TAR_GZ_ARCHIVE="coinhsl-archive.tar.gz"
HSL_TAR_GZ_ARCHIVE="none"

##############################################################################
# Phoenix Environment
##############################################################################
rm -f phoenix-env-latest.zip

curl -O https://dynamicoptimization.de/downloads/phoenix-env-latest.zip

if [[ -d phoenix-env-latest ]]; then
    sudo rm -Rf phoenix-env-latest
fi

unzip phoenix-env-latest.zip

pushd phoenix-env-latest

# phoenix deb-package
PHOENIX_DPKG=$(find . -maxdepth 1 -name "phoenix_*.deb" | wc -l)

if [[ ${PHOENIX_DPKG} -eq 1 ]]; then
    echo "Found phoenix debian package. Installing..."
    sudo dpkg -i phoenix_*.deb
elif [[ ${PHOENIX_DPKG} -gt 1 ]]; then
    echo "ERROR: Found more than one phoenix debian package. Aborting."
    return
else
    echo "ERROR: Phoenix debian package not found. Aborting."
    return
fi

# phoenix vsix-package
if code -v &> /dev/null; then
    PHOENIX_VSIX=$(find . -maxdepth 1 -name "jd.phoenix*.vsix" | wc -l)
    
    if [[ ${PHOENIX_VSIX} -eq 1 ]]; then
        echo "Found phoenix vsix package. Installing..."
        code --install-extension jd.phoenix*.vsix
    elif [[ ${PHOENIX_VSIX} -gt 1 ]]; then
        echo "Found more than one phoenix vsix package. Aborting."
        return
    else
        echo "WARNING: phoenix vsix package not found."
    fi
else
    echo "Code command not found. Aborting."
    return
fi

# pxpy whl-package
PXPY_WHEEL=$(find . -maxdepth 1 -name "pxpy*.whl" | wc -l)

if [[ ${PXPY_WHEEL} -eq 1 ]]; then
    echo "Found pxpy python package. Installing..."

    if [[ -d build ]]; then
        sudo rm -Rf build
    fi

    mkdir -p build

    cp "pxpy"*.whl build

    pushd build

    python3 -m pip uninstall -y pxpy &> /dev/null

    python3 -m pip install --user "pxpy"*.whl

    popd

    sudo rm -Rf build

elif [[ ${PXPY_WHEEL} -gt 1 ]]; then
    echo "ERROR: Found more than one pxpy python package. Aborting."
    return
else
    echo "ERROR: pxpy python package not found. Aborting."
    return
fi

popd

##############################################################################
# Phoenix-OC
##############################################################################
rm -f phoenix-oc-latest.zip

curl -O https://dynamicoptimization.de/downloads/phoenix-oc-latest.zip

if [[ -d phoenix-oc-latest ]]; then
    sudo rm -Rf phoenix-oc-latest
fi

unzip phoenix-oc-latest.zip

pushd phoenix-oc-latest

# pxoc whl-package
PXOC_WHEEL=$(find . -maxdepth 1 -name "pxoc*.whl" | wc -l)

if [[ ${PXOC_WHEEL} -eq 1 ]]; then
    echo "Found pxoc python package. Installing..."

    if [[ -d build ]]; then
        sudo rm -Rf build
    fi

    mkdir -p build

    cp "pxoc"*.whl build

    pushd build

    python3 -m pip uninstall -y pxoc &> /dev/null

    python3 -m pip install --user "pxoc"*.whl

    popd

    sudo rm -Rf build

elif [[ ${PXOC_WHEEL} -gt 1 ]]; then
    echo "ERROR: Found more than one pxoc python package. Aborting."
    return
else
    echo "ERROR: pxoc python package not found. Aborting."
    return
fi

popd

##############################################################################
# IPOPT
##############################################################################
IPOPT_DPKG=$(find . -maxdepth 1 -name "ipopt_*.deb" | wc -l)

if [[ ${IPOPT_DPKG} -gt 1 ]]; then
    echo "Error: Found more than one ipopt debian package. Aborting."
    return
elif [[ ${IPOPT_DPKG} -ne 1 ]]; then
    if [[ -d build ]]; then
        sudo rm -Rf build
    fi

    mkdir -p build

    pushd build

    ARCH=$(dpkg --print-architecture)

    IPOPT_SUPPORTED_VERSION="3.14.4"

    IPOPT_DPKG_NAME=ipopt_${IPOPT_SUPPORTED_VERSION}_${ARCH}

    IPOPT_DPKG_PREF=$(pwd)/${IPOPT_DPKG_NAME}/opt/apps/ipopt

    IPOPT_DPKG_MODF=$(pwd)/${IPOPT_DPKG_NAME}/opt/apps/modulefiles

    IPOPT_DPKG_LIBS=${IPOPT_DPKG_PREF}/lib

    mkdir -p ${IPOPT_DPKG_PREF}

    mkdir -p ${IPOPT_DPKG_MODF}

    mkdir -p ${IPOPT_DPKG_LIBS}

    mkdir -p ${IPOPT_DPKG_NAME}/DEBIAN

    chmod -R 0755 ${IPOPT_DPKG_NAME}/DEBIAN

    HSL_COUNT=0
    if [ "${HSL_TAR_GZ_ARCHIVE}" = "none" ]; then
        echo "No HSL archive specified." 
    else
        HSL_COUNT=$(find .. -maxdepth 1 -name "${HSL_TAR_GZ_ARCHIVE}" | wc -l)

        if [[ ${HSL_COUNT} -gt 1 ]]; then
            echo "ERROR: found more than one HSL archive matching ${HSL_TAR_GZ_ARCHIVE}. Aborting."
            return
        fi
    fi

    CC=gcc

    CXX=g++

    FC=gfortran

    export CC CXX FC

    if [[ ${HSL_COUNT} -eq 0 ]]; then
        echo "Did not find HSL archive. Configuring ipopt module with MUMPS..."

        if [[ -d ThirdParty-Mumps ]]; then 
            rm -Rf ThirdParty-Mumps
        fi

        git clone https://github.com/coin-or-tools/ThirdParty-Mumps.git
        
        pushd ThirdParty-Mumps
        
        ./get.Mumps
        
        ./configure --prefix=${IPOPT_DPKG_PREF}
        
        make --jobs=2
        
        sudo make install
        
        popd
    fi

    if [[ ${HSL_COUNT} -eq 1 ]]; then
        
        echo "Found HSL archive. Configuring ipopt module with HSL..."
        
        if [[ -d ThirdParty-HSL ]]; then 
            rm -Rf ThirdParty-HSL
        fi

        git clone https://github.com/coin-or-tools/ThirdParty-HSL
        
        cp ../$HSL_TAR_GZ_ARCHIVE ThirdParty-HSL
        
        pushd ThirdParty-HSL

        mkdir -p coinhsl
        
        tar xf $HSL_TAR_GZ_ARCHIVE -C coinhsl --strip-components=1

        ./configure --prefix=${IPOPT_DPKG_PREF}
        
        make --jobs=2
        
        make install
        
        popd
    fi

    IPOPT_FILE=Ipopt-${IPOPT_SUPPORTED_VERSION}.tar.gz

    curl -O https://www.coin-or.org/download/source/Ipopt/$IPOPT_FILE

    tar xf ${IPOPT_FILE}

    mv Ipopt-releases-*${IPOPT_SUPPORTED_VERSION}* Ipopt

    pushd Ipopt

    if [[ ${HSL_COUNT} -eq 1 ]]; then
        ./configure --prefix=${IPOPT_DPKG_PREF} --disable-java --without-asl --without-mumps --with-hsl --with-hsl-lflags="-L${IPOPT_DPKG_PREF}/lib -lcoinhsl" --with-hsl-cflags="-I${IPOPT_DPKG_PREF}/include/coin-or/hsl"
    fi

    if [[ ${HSL_COUNT} -eq 0 ]]; then
        ./configure --prefix=${IPOPT_DPKG_PREF} --disable-java --without-asl --without-hsl --with-mumps --with-mumps-lflags="-L${IPOPT_DPKG_PREF}/lib -lcoinmumps" --with-mumps-cflags="-I${IPOPT_DPKG_PREF}/include/coin-or/mumps" --disable-linear-solver-loader
    fi

    make --jobs=2

    sudo make install

    popd

    if ls /lib/x86_64-linux-gnu/lapack/*.so* 1> /dev/null 2>&1; then
        sudo cp /lib/x86_64-linux-gnu/lapack/*.so* ${IPOPT_DPKG_PREF}/lib
    else
        echo "LAPACK shared libraries not found in /lib/x86_64-linux-gnu/lapack/"
    fi

    if ls /lib/x86_64-linux-gnu/blas/*.so* 1> /dev/null 2>&1; then
        sudo cp /lib/x86_64-linux-gnu/blas/*.so* ${IPOPT_DPKG_PREF}/lib
    else
        echo "BLAS shared libraries not found in /lib/x86_64-linux-gnu/blas/"
    fi

    tee ${IPOPT_DPKG_MODF}/ipopt<<EOF
#%Module1.0#####################################################################
proc ModulesHelp { } {
    global version modroot
    pcuts stderr "module for the Interior Point OPTimizer (IPOPT) version ${IPOPT_SUPPORTED_VERSION}"
}
module-whatis   "Set up environment for using IPOPT"
# for Tcl script use only
set     version         ${IPOPT_SUPPORTED_VERSION}
set     sys             linux86
prepend-path    LD_LIBRARY_PATH     /opt/apps/ipopt/lib
setenv          IPOPT_INCLUDE_DIR   /opt/apps/ipopt/include
setenv          IPOPT_LIB_DIR       /opt/apps/ipopt/lib
EOF

    tee ${IPOPT_DPKG_NAME}/DEBIAN/control<<EOF
Package: ipopt
Version: ${IPOPT_SUPPORTED_VERSION}
Architecture: ${ARCH}
Maintainer: ${USER}
Description: Interior Point OPTimizer (IPOPT) - An open-source software for nonlinear optimization (see https://coin-or.github.io/Ipopt/).
EOF

    dpkg-deb --build --root-owner-group ${IPOPT_DPKG_NAME}

    sudo cp ${IPOPT_DPKG_NAME}.deb ..

    popd
fi

sudo dpkg -i ipopt_*.deb

##############################################################################
# Slurm (Minimal)
##############################################################################
sudo tee /etc/slurm-llnl/slurm.conf <<EOF
ClusterName=cluster
SlurmctldHost=$(hostname -f)
ProctrackType=proctrack/linuxproc
ReturnToService=2
SlurmdSpoolDir=/var/lib/slurm-llnl/slurmd
StateSaveLocation=/var/lib/slurm-llnl/slurmctld
SlurmctldLogFile=/var/log/slurm-llnl/slurmctld.log
SlurmdLogFile=/var/log/slurm-llnl/slurmd.log
NodeName=$(hostname -f) ThreadsPerCore=2 State=UNKNOWN
PartitionName=local Default=Yes Nodes=ALL State=UP
EOF

##############################################################################
# OpenMPI Module File (Placeholder)
##############################################################################
if [[ ! -f  /opt/apps/modulefiles/openmpi ]]; then
    sudo tee /opt/apps/modulefiles/openmpi <<EOF
#%Module1.0
proc ModulesHelp { } {
    puts stderr "Placeholder module file for setting up Open MPI."
}

module-whatis "Placeholder module file for setting up Open MPI."
EOF
fi

##############################################################################
# Link Modules
##############################################################################
PREFIX_MODULE_DIR=/opt/apps/modulefiles

TARGET_MODULE_DIR="/usr/share/modules/modulefiles"

MODULES=("openmpi" "ipopt" "phoenix")

if [ ! -d "$TARGET_MODULE_DIR" ]; then
    echo "Error: Target directory $TARGET_MODULE_DIR does not exist."
    return
fi

for MODULE in "${MODULES[@]}"; do
    if [ ! -f "$PREFIX_MODULE_DIR/$MODULE" ]; then
        echo "Error: Module file $PREFIX_MODULE_DIR/$MODULE does not exist."
        return
    fi

    if [ -e "$TARGET_MODULE_DIR/$MODULE" ]; then
        echo "Warning: Module file $TARGET_MODULE_DIR/$MODULE already exists. Deleting..."
        sudo rm -f "$TARGET_MODULE_DIR/$MODULE"
    fi

    sudo ln -s "$PREFIX_MODULE_DIR/$MODULE" "$TARGET_MODULE_DIR/$MODULE"

    if [ $? -eq 0 ]; then
        echo "Symlink created for $MODULE."
    else
        echo "Error: Failed to create symlink for $MODULE."
        return
    fi
done

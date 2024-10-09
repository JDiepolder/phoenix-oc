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
# This script serves as a template for checking if the environment and essential 
# software components are set up correctly. 
#
# It is intended to be modified according to your specific needs.
#
# THOROUGLY TEST THE SCRIPT IN A CONTROLLED ENVIRONMENT BEFORE ANY USE!
#

clear;
echo -e "\033[1m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0m"
echo -e "\033[1m PHOENIX STARTUP \033[0m"
echo -e "\033[1m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0m"
ERRORS=0

# Check if pxpy module is installed
if python3 -c "import pxpy" &> /dev/null; then
    echo " ✔ Phoenix python module installed."
else
    echo -e "\033[31m ✘ Phoenix python module not installed.\033[0m"
    ((ERRORS++))
fi

# Check if gunicorn process is running, and start it if it isn't
if ! pgrep -f 'gunicorn.*pxpy.pxrest:app' &> /dev/null; then
    if gunicorn --workers 2 --bind 127.0.0.1:8082 --daemon pxpy.pxrest:app &> /dev/null; then
        echo " ✔ Phoenix REST API started."
    else
        echo -e "\033[31m ✘ Phoenix REST API could not be started.\033[0m"
        ((ERRORS++))
    fi
else
    echo " ✔ Phoenix REST API running."
fi

# Attempt to load the phoenix environment module and check its version
if module load phoenix > /dev/null 2>&1; then
    PHOENIX_VERSION=$(phoenix --version)
    echo " ✔ Phoenix ${PHOENIX_VERSION} environment module sucessfully loaded."
else
    echo -e "\033[31m ✘ Phoenix environment module could not be loaded.\033[0m"
    ((ERRORS++))
fi

# Check if munge service for slurm is available, and start service if it isn't
if sudo service munge status &> /dev/null; then
    echo " ✔ Slurm munge service running."
else
    if sudo service munge start &> /dev/null; then
        echo " ✔ Slurm munge service started."
    else
        echo -e "\033[31m ✘ Slurm munge service could not be started.\033[0m"
        ((ERRORS++))
    fi
fi

# Check if slurmctld service for slurm is available, and start service if it isn't
if sudo service slurmctld status &> /dev/null; then
    echo " ✔ Slurm management service running."
else
    if sudo service slurmctld start &> /dev/null; then
        echo " ✔ Slurm management service started."
    else
        echo -e "\033[31m ✘ Slurm management service could not be started.\033[0m"
        ((ERRORS++))
    fi
fi

# Check if slurm daemon is available, and start service if it isn't
if sudo service slurmd status &> /dev/null; then
    echo " ✔ Slurm daemon running."
else
    if sudo service slurmd start &> /dev/null; then
        echo " ✔ Slurm daemon started."
    else
        echo -e "\033[31m ✘ Slurm daemon could not be started.\033[0m"
        ((ERRORS++))
    fi
fi

echo -e "\033[1m~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\033[0m"
if [[ ERRORS -eq 0 ]]; then 
    echo -e " ✔ Startup completed successfully.\n"
else
    echo -e "\033[31m ✘ ${ERRORS} check(s) failed, implying the environment is not fully configured.\n\033[0m"
    echo -e "\nIf this is a first-time setup, consider running the install script as follows:\n"
    echo -e "\n\033[1msource phoenix_install.sh 2>&1 | tee phoenix_install.log; source phoenix_startup.sh\033[0m\n\n"
fi

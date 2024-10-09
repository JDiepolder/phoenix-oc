# Base image
FROM mcr.microsoft.com/devcontainers/universal:2-linux

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install Debian packages as root
RUN apt-get update && apt-get install -y \
    liblapack-dev \
    openmpi-bin \
    pandoc \
    environment-modules \
    pkg-config \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    python3 \
    python3-pip \
    slurmd \
    slurmctld \
    slurm-client \
    munge \
    build-essential \
    gfortran \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Switch to user
USER codespace

# Install Python packages as user
RUN python3 -m pip install Flask flask_expects_json gunicorn jsonpatch jsonschema \
    jsmin regex requests setuptools graphlib-backport Cython numpy scipy ipympl \
    matplotlib notebook zstandard nbconvert pymongo \
    && python3 -c "import matplotlib.pyplot"

# Enable module load for user 
RUN echo "if [ -f /etc/profile.d/modules.sh ]; then . /etc/profile.d/modules.sh; fi" >> ~/.bashrc

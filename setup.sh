#!/bin/bash
PROJECT_STARTER_CODE="https://raw.githubusercontent.com/markandeyp/pi-vision/main/app.py"
PROJECT_STARTER_IMAGE="https://raw.githubusercontent.com/markandeyp/pi-vision/main/placeholder.png"
ORIGINAL_USER=$1
echo "Original user: $ORIGINAL_USER"
# First, check if Python 3 is available. If not, terminate the script and ask the user to fix that.
if ! which python3
then
    sudo -u $ORIGINAL_USER -- echo "Python3 does not appear to be installed on your system. Please install it and try running this script again."
    exit 1
fi

# Identify the OS we're on — they have some special installation requirements
LINUX_OS_FILE_LOCATION=/etc/os-release

if test -f "$LINUX_OS_FILE_LOCATION" 
then
    if grep -q raspbian $LINUX_OS_FILE_LOCATION
    then
        LOCAL_OS="Raspbian"
    else
        LOCAL_OS="Linux"
    fi
else
    LOCAL_OS="Mac"
fi

# If we're on a Linux system, update apt-get's lists too
if test $LOCAL_OS == "Linux" -o $LOCAL_OS == "Raspbian"
then
    echo "Running $LOCAL_OS"
    apt-get update
    apt-get install libjpeg-dev zlib1g-dev 
fi

# If we're on some flavour of Linux we may need to install wheel to allow us to install the packages we'll need
if test $LOCAL_OS == "Linux"
then
    apt-get install python3-pip
    apt-get install python3-wheel
fi

# Upgrade pip3 & setuptools before we use it to install anything else we need
sudo -u $ORIGINAL_USER -- python3 -m pip install --user --upgrade pip

sudo -u $ORIGINAL_USER -- python3 -m pip install --upgrade setuptools

# Check for guizero and install if needed
sudo -u $ORIGINAL_USER -- python3 -c "import guizero" > /dev/null 2>&1
if test $? == 0
then
    echo "Guizero already installed. Upgrading."
    sudo -u $ORIGINAL_USER -- python3 -m pip install --user guizero[images] -U
else
    sudo -u $ORIGINAL_USER -- python3 -m pip install --user guizero[images]
fi

# Check for numpy and install if needed
sudo -u $ORIGINAL_USER -- python3 -c "import numpy" > /dev/null 2>&1
if test $? == 0
then
    echo "Numpy already installed."
else
    sudo -u $ORIGINAL_USER -- python3 -m pip install --user -Iv numpy
fi

# Check for PIL and install if needed
sudo -u $ORIGINAL_USER -- python3 -c "import PIL" > /dev/null 2>&1
if test $? == 0
then
    echo "Pillow already installed. Upgrading."
    sudo -u $ORIGINAL_USER -- python3 -m pip install --user pillow -U
else
    sudo -u $ORIGINAL_USER -- python3 -m pip install --user pillow
fi

# Check for tensorflow and install if needed
sudo -u $ORIGINAL_USER -- python3 -c "import tensorflow" > /dev/null 2>&1
if test $? == 0
then
    echo "Tensorflow already installed."
else
    if test $LOCAL_OS == "Raspbian"
    then
        apt-get install gfortran
        apt-get install libhdf5-dev libc-ares-dev libeigen3-dev
        apt-get install libatlas-base-dev libopenblas-dev libblas-dev
        apt-get install liblapack-dev cython
        sudo -u $ORIGINAL_USER -- python3 -m pip install --user pybind11
        sudo -u $ORIGINAL_USER -- python3 -m pip install --user h5py
        sudo -u $ORIGINAL_USER -- python3 -m pip install --user gdown
        cp /home/$ORIGINAL_USER/.local/bin/gdown /usr/local/bin/gdown
        sudo -u $ORIGINAL_USER gdown https://drive.google.com/uc?id=11mujzVaFqa7R1_lB7q0kVPW22Ol51MPg
        sudo -u $ORIGINAL_USER  -H python3 -m pip install --user tensorflow-2.2.0-cp37-cp37m-linux_armv7l.whl
        rm tensorflow-2.2.0-cp37-cp37m-linux_armv7l.whl
    else
        sudo -u $ORIGINAL_USER python3 -m pip install --user -Iv tensorflow
    fi
fi

# Make a folder to hold the project
sudo -u $ORIGINAL_USER -- mkdir ./pi-vision

# Get the starter code
sudo -u $ORIGINAL_USER -- curl $PROJECT_STARTER_CODE > ./pi-vision/app.py

# Make the user the owner of the starter code
chown $ORIGINAL_USER ./pi-vision/app.py

#Get the placeholder image
sudo -u $ORIGINAL_USER -- curl $PROJECT_STARTER_IMAGE > ./pi-vision/placeholder.png

# Make the user the owner of the placeholder image
chown $ORIGINAL_USER ./pi-vision/placeholder.png
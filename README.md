# Pothole-Detection-Flask-API
A flask API that predicts if an image has a plothole in it using tensorflow model generated though CNN.

## Installation
### 1. Install Anaconda.
Following instructions are given for anaconda installation in Ubuntu.
Installation can also be done without anaconda using pipenv.

### 2. Create a new virtual environment.
tf is the name of environment.

`conda create --name tf` 
or `conda create --name tf python=3.7` specify the version of python 3 you have

Activate the environment before installing libraries

`conda activate tf`

### 3. Install packages
Libraries required for running are as follows.
Tensorflow 2.0,
Keras 2.3,
Opencv 3.4.1,
numpy,
matplotlib
and Flask
Install the libraries using conda by the following commands. Ensure the version of package before hitting y.
```
conda install numpy
conda install matplotlib
conda install tensorflow
conda install keras
conda install opencv
```
And install flask `conda install flask`

## Running
Clone the repository

Activate the environment.
`conda activate tf`
Close any app taking too much memory before running to prevent unresponsive pc. It consumes a ram of about 6-7 GB.
Having swap m
```
conda activate myenv
export FLASK_APP=app.py
flask run
```
To stop the server hit CTRL+C.
Deactivate the environment with `conda deactivate`.


##App information 
There is an user app from which any person upload an potholes image and its location is detected and it will be verified using ML and it will be reported to the executive. 

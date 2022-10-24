# Instructions

One way to install Pystan 3 on windows is to do so using WSL2. The general steps to install pystan 3 are as follows:

1. Install WSL with a Ubuntu Distribution
2. Download and install an Anaconda distribution onto your WSL Ubuntu VM
3. Install GCC
4. Install Pystan3

## 1. Installing WSL with a Ubuntu Distribution

a. Open windows powershell and run as administrator (right click, run as administrator) and type

```
wsl --install
```
b. Restart your system
c. Open ubuntu and type your chosen credentials. For this tutorial my user name will be "stan"
d. Type
```
wsl -l
```
to ensure you have a ubuntu distribution available

## 2. Download and install an Anaconda distribution onto your WSL Ubuntu VM

a. Go to your project folder. You can do this in powershell or you IDE (e.g., PyCharm). Type

```
wsl -d Ubuntu
```
b. Go to https://repo.continuum.io/archive and select a linux anaconda release, e.g., Anaconda3-2022.10-Linux-x86_64.sh. Choose something x86.sh for 32 bit version computer.

c. In your linux console type

```
wget https://repo.continuum.io/archive/Anaconda3-2022.10-Linux-x86_64.sh
```
Obviously replace with the text with your specific version. This will download the file to your linux distro

d. Install python by typing
```
bash Anaconda3-2022.10-Linux-x86_64.sh
```

Remember, when it asks you:
```
Do you wish the installer to initialise Anaconda3?
```
Say yes!


e. Close the session by typing

```
exit
```

f. Open linux again by typing
```
wsl -d Ubuntu
```

g. Verify everything worked by typing
```
which python
```
It should appear with the version of python in an anaconda folder. e.g., "/home/stan/anaconda3/bin/python". Here
"stan" is the username. It will be different if you used a different user name.

If nothing appears, you will need to add python to the path. Go to trouble shooting at the end of this document.


## 3. Install GCC

a. In your linux console type:

```
sudo apt update
sudo apt install build-essential
sudo apt-get install manpages-dev
```

b. Verify it worked by typing
```
gcc --version
```
You should get: "/usr/bin/gcc"

If you don't get anything, you need to add gcc to the path. Go to trouble shooting at the end of this document.


## 4. Install Pystan3

a. Creat a conda virtual environment. Make sure to specify the version of python you wish to use.

```
create conda enviroment
conda create -n stan_env python=3.9
conda activate stan_env
```
b. Install pystan3

```
pip install pystan
```

c. In a text editor of your choice, create a test_stan.py file in your project folder. Fill test_stan.py with the contents test_stan.py in this repo along side these instructions

d. In linux, type
```
python main.py
```
If this works, congratulations you've now installed Pystan3 on windows through WSL2

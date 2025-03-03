# WISC_MVPA_Apptainer
Set up Apptainer in which to run WISC MVPA (https://github.com/crcox/WISC_MVPA). 

## Quickstart

1. **Compile code** by running `compile_WISC_MVPA.sh`. This script is designed to run on the CBU cluster. If you are trying to run it elsewhere, check that:
	- You have an installation of Anaconda and that the script is pointing to your installation
	- You have a conda environment set up according to the instructions in `setup_conda_environment.txt`
	- You have MATLAB installed and licensed, and that the script is pointing to your installation
	- The MATLAB version that you are using to compile the code is the same as the version of the runtime that you will install in the container (see `WISC_MVPA_runtime.def` - this script uses r2023b by default)
2. **Move things to your home directory on CHTC** using the terminal or PowerShell. All the things that you need to move are contained in `apptainer_setup.tar.gz`. Once you have done so, extract the files (`tar zxvf apptainer_setup.tar.gz`).
3. **Build the container**:
```
condor_submit -i build.sub
# and when the job begins:
apptainer build WISC_MVPA.sif WISC_MVPA_runtime.def
# and when the build is finished:
exit
```


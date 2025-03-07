# WISC_MVPA_Apptainer
Set up Apptainer in which to run WISC MVPA (https://github.com/crcox/WISC_MVPA). 

## Quickstart

1. **Compile code** by running `compile_WISC_MVPA.sh`. This script is designed to run on the CBU cluster. If you are trying to run it elsewhere, check that:
	- You have an installation of Anaconda and that the script is pointing to your installation
	- You have a conda environment set up according to the instructions in `setup_conda_environment.txt`
	- You have MATLAB installed and licensed, and that the script is pointing to your installation
	- The MATLAB version that you are using to compile the code is the same as the version of the runtime that you will install in the container (see `WISC_MVPA.def` - this script uses r2023b by default)
2. **Move things to your home directory on CHTC** using the terminal or PowerShell. All the things that you need to move are contained in `apptainer_setup.tar.gz`. Once you have done so, extract the files (`tar -zxvf apptainer_setup.tar.gz`).
3. **Build the container**:
```
condor_submit -i build.sub
# and when the job begins:
apptainer build WISC_MVPA.sif WISC_MVPA.def
# and when the build is finished:
exit
```
4. **Test the container (optional)**. In your home directory on CHTC:
```
# enter the container
apptainer shell -e WISC_MVPA.sif
# extract the test data
tar -zxvf test_data.tar.gz
# navigate into the test job directory
cd 00
# run the analysis
/WISC_MVPA
# if successful, verbose output will be produced and the directory 00 will then contain results.mat .
```
5. **Move the container to your `staging` directory** (this is recommended by CHTC because of the size of the containers - although this container is reasonably small at ~5 GB). 
6. **Add the container to your .sub files** by following the instructions on the CHTC website (https://chtc.cs.wisc.edu/uw-research-computing/apptainer-htc). Note that the WISC MVPA workflow usually uses flocking (the jobs "flock" to unused computers on the UW-Madison campus), so follow the instructions that enable +WantFlocking. 
7. **Submit jobs!**



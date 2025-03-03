#!/bin/bash

# Compiles WISC_MVPA code on the CBU cluster. Bundles compiled code with a .def file and a fake dataset that can be used to test a container 

cd /group/mlr-lab/Saskia/WISC_MVPA_Apptainer
# add path
export PATH=$PATH:/imaging/local/software/anaconda/latest/x86_64/bin/
# get dependencies
git clone https://github.com/crcox/WISC_MVPA.git
git clone https://github.com/MartinKoch123/yaml.git

# 1. COMPILE WISC MVPA

cd WISC_MVPA

# edit the Makefile to the MATLAB install on the CBU cluster
awk 'NR==2 {$0="MATLABDIR ?= /hpc-software/matlab/r2023b"} 1' Makefile > temp && mv temp Makefile

# tarball source code and dependencies
make sdist

# mimic a CHTC interactive build job by making a temporary directory, moving the items to that directory that would usually be transferred to the build job, running the job, and transferring files out again. 
mkdir tmp
cp Makefile tmp
cp source_code.tar.gz tmp
cd tmp
make all
cp WISC_MVPA ../
cd ../
rm -r tmp

# 2. MAKE TEST DATASET

# get dependencies
cd /group/mlr-lab/Saskia/WISC_MVPA_Apptainer

# make dataset and .yamls
matlab_r2023b -nodisplay -nodesktop -r "addpath('/group/mlr-lab/Saskia/WISC_MVPA_Apptainer');make_test_dataset;exit"

# setupJobs
source activate WISC_MVPA
cd /group/mlr-lab/Saskia/WISC_MVPA_Apptainer/tune
setupJobs visualize_tune.yaml

# only the first job directory will be part of the test dataset
cp -r 00 ../

# 3. MAKE TARBALL

cd /group/mlr-lab/Saskia/WISC_MVPA_Apptainer

# tarball test data (for unzipping in container)
tar -zcvf test_data.tar.gz test_data 00
# tarball compiled code, .def and .sub files (for unzipping on login node), and test dataset. Do in a temporary directory to avoid name conflicts
mkdir tmp
cp WISC_MVPA/WISC_MVPA tmp
cp WISC_MVPA_runtime.def tmp
cp build.sub tmp
cp test_data.tar.gz tmp
cd tmp
tar -zcvf /group/mlr-lab/Saskia/WISC_MVPA_Apptainer/apptainer_setup.tar.gz WISC_MVPA WISC_MVPA_runtime.def build.sub test_data.tar.gz

# cleanup
cd /group/mlr-lab/Saskia/WISC_MVPA_Apptainer
rm -r 00
rm -r test_data
rm -r tmp
rm -r tune
rm -r WISC_MVPA
rm -r yaml
rm test_data.tar.gz








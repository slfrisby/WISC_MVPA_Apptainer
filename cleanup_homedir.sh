#!/bin/bash

# Cleans up the CHTC home directory after container build - and self-destructs!
rm -r 00
rm build.sub build.log apptainer_setup.tar.gz test_data.tar.gz WISC_MVPA WISC_MVPA.def
rm cleanup_homedir.sh

# Building Geant 4 apptainer with LEPP patches

## Installing apptainer

TO BE DONE...

## Building the apptainer image

Just clone the repository, and make:

```
git clone git@github.com:LEPP-Heidelberg/apptainers.git
cd apptainers
make
make clean
```

This should create a file with a name like
geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif that you can
use.

If you ever need to find out what software versions went into the apptainer
image, you can learn about this either:

- by using the apptainer metadata
```
# apptainer inspect -H geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif
Geant4 built from geant4-11.3-release-lepp branch with LEPP patches (2149aef8008b2e34f79898be75d2c9d66c41f77f)
Built with system xerces-c for GDML support
ROOT built from v6-36-00-patches branch is available (015dbec02fec27b46a325512dd1a439d70b32ac0)
Based on Ubuntu 24.04
```

- by inspecting environment variables inside the apptainer:
```
# apptainer shell geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif
Apptainer> echo $UBUNTU_VERSION
24.04
```
The environment variables ```UBUNTU_VERSION```, ```ROOT_BRANCH```, ```ROOT_BRANCH_HASH```,
```GEANT4_BRANCH``` and ```GEANT4_BRANCH_HASH``` are defined.

# Using the apptainer

TO BE DONE...

# Making a new release of the apptainer image(s)

If there is a new ROOT release, or additional patches in the Geant 4 code that
need to be included, getting these into the apptainer image is not difficult.
It involves these steps:

- commenting out the branch hash at the beginning of ```Makefile```
- rebuilding the image(s)
- updating the corresponding hash(es) in the commented-out lines
- and re-enabling the commented-out line

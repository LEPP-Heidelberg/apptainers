# SuperSUN Geant4 / Apptainer Workflow

This guide describes how to set up and maintain your local working environment for the custom geant4-11.3-release-lepp branch, including building simulations with Apptainer, managing branches, and contributing changes safely.

---

## 0. Code Structure

The GEANT4-UCN SuperSUN model is built on a fork of the main GEANT4 repository https://github.com/Geant4/geant4.git, and run in an Apptainer container for portability. The code base on LEPP-Heidelberg's GitHub is set up as follows:

```
LEPP-Heidelberg/
├── geant4/
│   ├── master $\leftarrow$ This is the main geant4 branch from upstream
│   └── geant4-11.3-release-lepp $\leftarrow$ This branch contains the LEPP modified version
│       └── examples/extended/exoticphysics/ucn $\leftarrow$ Source code of the SuperSUN model
└── apptainers/
│   ├── geant4-lepp-root-ubuntu.def $\leftarrow$ Apptainer container definition file within which the simulations run and compile
│   └── garfieldpp-root-ubuntu.def $\leftarrow$ Apptainer container definition file for Garfield++
└── other-lepp-repos
```

The geant4/ repository is used to develop or maintain the source code.
The definition under apptainers/ sets up the full environment, and installs the simulation software from geant4/.

## 1. Initial Setup

### 1.0 Configure Git Identity

When you commit something with ```git```, this will set your name and e-mail
address which are shown for each of your commits.

```
git config --global user.name "Your Name"
git config --global user.email "name@example.com"
```

### 1.1 Create a Workspace

```
mkdir -p ~/git_repos
cd ~/git_repos
```

### 1.2 Clone the Geant4 Repository (development)

```
git clone -b geant4-11.3-release-lepp https://github.com/LEPP-Heidelberg/geant4.git
cd geant4
```

### 1.3 Clone the Apptainers Repository (running the latest stable release)

```
cd ~/git_repos
git clone https://github.com/LEPP-Heidelberg/apptainers.git
```

---

## 2. Setup and run

### 2.1 Optional: Build your SIF

```
cd ~/git_repos/apptainers
make
make clean
```

This should create a file with the name geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif, this is the container. To run the simulations one can either run commands through:

```
apptainer exec ~/git_repos/geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif <some command>
```

Or by working within the apptainer CLI, entered using:

```
apptainer exec ~/git_repos/geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif /bin/bash
```

#### Building the Geant4 and Garfield++ images separately

```make``` builds both the Geant4 and the Garfield++ image. To build only one
of them, use ```make geant4``` or ```make garfieldpp```. The Garfield++ image
is called garfieldpp-master-root-v6-40-00-patches-ubuntu24.04.sif.

The two images can use different ROOT versions: ```ROOT_BRANCH```/
```ROOT_BRANCH_HASH``` set the ROOT used for Geant 4, and
```GARFIELD_ROOT_BRANCH```/```GARFIELD_ROOT_BRANCH_HASH``` the one used for
Garfield++ (both in the ```Makefile```). Each ROOT version is built only once
(this takes a few hours), and the resulting tarball is reused; if both point to
the same hash, the ROOT build is shared.

#### Finding out which software versions are in an image

If you ever need to find out what software versions went into an apptainer
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
The environment variables ```UBUNTU_VERSION```, ```ROOT_BRANCH```,
```ROOT_BRANCH_HASH```, ```GEANT4_BRANCH``` and ```GEANT4_BRANCH_HASH``` are
defined (in the Garfield++ image, ```GARFIELD_BRANCH``` and
```GARFIELD_BRANCH_HASH``` instead of the Geant 4 ones).

### 2.2 Create a Wrapper Command (~/bin/g4run) (Optional)

Create the file ~/bin/g4run:

```
#!/bin/bash
apptainer exec --bind ~/git_repos/geant4:/workdir ~/git_repos/apptainers/geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif "$@"
```

Make it executable:

```
chmod +x ~/bin/g4run
```

Create the file ~/.bashrc

```
vim ~/.bashrc
```

Enter the text:

```
# Set PATH for local executables in ~/bin
if [ -d "$HOME/bin" ]; then
  # Use 'export' to make the change available to sub-processes
  export PATH="$HOME/bin:$PATH"
fi
```

Run:

```
source ~/.bashrc
```

Usage Example:

```
g4run cmake ../some-source-code
g4run make -j 8
g4run ./ExUCN -m vis.mac
```

The command ```g4run``` is used as a shorthand for ```apptainer exec ~/git_repos/apptainers/geant4-11.3-release-lepp-root-v6-36-00-patches-ubuntu24.04.sif <some command>``` in what follows.

### 2.3 Running a simulation

The geant4 installation, pulled from the LEPP-Heidelberg/geant4/tree/geant4-11.3-release-lepp branch lives under ```/opt/geant4```. In some working directory:

```
mkdir ucn_build
cd ucn_build
g4run cmake /opt/geant4/examples/extended/exoticphysics/ucn
g4run make
```

The simulation settings may be controlled by editing the macro (.mac) file, by default ```vis.mac```. A simulation is then run using:

```
g4run ./ExUCN -m vis.mac # or alternatively your_macro.mac
```

This should output a start.txt, output.txt and if requested ```(timestep>0)``` a snapshot.txt. NOTE: An energy spectrum (.dat), formatted as two space separated columns Energy [neV], Intensity [Counts] must be supplied to initialise the simulation.

### 2.4 Updating to newer releases

To be filled in.

### 2.5 Using the Garfield++ image

Garfield++ (from https://gitlab.cern.ch/garfield/garfieldpp.git) is installed
under ```/opt/garfieldpp```, built against its own ROOT version (see 2.1).
Inside the container, ```GARFIELD_INSTALL```, ```HEED_DATABASE```,
```LD_LIBRARY_PATH``` and ```CMAKE_PREFIX_PATH``` are set up automatically, so
a program using Garfield++ (with ```find_package(Garfield)``` in its
```CMakeLists.txt```) can be built and run like the Geant 4 simulation above:

```
mkdir my_garfield_build
cd my_garfield_build
apptainer exec ~/git_repos/apptainers/garfieldpp-master-root-v6-40-00-patches-ubuntu24.04.sif cmake ../my-garfield-code
apptainer exec ~/git_repos/apptainers/garfieldpp-master-root-v6-40-00-patches-ubuntu24.04.sif make
```

#### Wrapper command for Garfield++ (~/bin/garfrun) (Optional)

Just like ```g4run``` (see 2.2), a shortcut command can be made for the
Garfield++ image. Create the file ~/bin/garfrun:

```
#!/bin/bash
apptainer exec ~/git_repos/apptainers/garfieldpp-master-root-v6-40-00-patches-ubuntu24.04.sif "$@"
```

Make it executable:

```
chmod +x ~/bin/garfrun
```

If you already set up ~/bin in your PATH for ```g4run```, nothing else is
needed. Otherwise, add the ~/.bashrc lines from 2.2. The example above then
becomes:

```
garfrun cmake ../my-garfield-code
garfrun make
```

### 2.6 Making a new release of the apptainer image(s)

If there is a new ROOT release, or additional patches in the Geant 4 code (or
new Garfield++ commits) that need to be included, getting these into the
apptainer image is not difficult. It involves these steps:

- commenting out the branch hash at the beginning of ```Makefile```
- rebuilding the image(s)
- updating the corresponding hash(es) in the commented-out lines
- and re-enabling the commented-out line

---

## 3. Development Cycle

### 3.1 Start a New Feature Branch

```
cd ~/git_repos/geant4
git fetch origin
git checkout geant4-11.3-release-lepp
git pull
git checkout -b <yourusername>_<feature>
```

Example:

```
git checkout -b name_ucn_test
```

There are many good reasons for this branching:

* If you work on a branch while you debug, you don't accidentally break
  everybody else's code.

* People can work in parallel without destabilising each other's work with
  disruptive changes.

* A branch is a convenient label that allows you to share your work with
  others. You can ask colleagues to take a look, and they can check out your
  branch if they're interested and are working on something related.

### 3.2 Make Edits

All code and input file modifications happen directly in your cloned repository.

Key Files to Edit:
* examples/extended/exoticphysics/ucn/src/

DO NOT edit anything inside the container itself, this would be overwritten when the apptainer is patched/updated. The container is for build/runtime on a stable version.

### 3.3 Build and Run using Apptainer

```
cd geant4/examples/extended/exoticphysics/ucn
mkdir -p ucn_build
cd ucn_build
```

#### Configure build

```
g4run cmake ../ucn
```

#### Compile (every time the source code is edited)

```
g4run make
```

#### Run simulation

```
g4run ./ExUCN -m vis.mac
```

### 3.4 Test Iteratively

* If you are working on anything, you should probably have created a branch
  with ```git checkout -b yourusername_feature```, see above. This will
  facilitate merging different branches with different features.

* Tweak macros/source code, rebuild, and rerun.

* On your own branch, you can commit early, and often. (The upside is that you can see what changed with ```git status``` and ```git diff```.)

* Once the feature or bugfix is fully tested and ready, you can push your branch to upstream with ```git push```, see below.

#### 3.4.1 Commit Changes

Committing in git is a two stage process. ```git add``` adds any local changes
you may have to the git index. In a second step, you can commit the changes
that you added to the index with ```git commit```.

```
git status
git add the-source-file(s).you.changed.cc
git commit -m "Describe your change clearly"
```

If you do not give the ```-m``` flag to the ```git commit``` command, it will
drop you into a text editor to edit your commit message interactively (which is
advisable for longer commits anyway).

A good commit message consists of:

* a one line summary of the change on the first line

* a statement of the problem that the change is trying to address

* a description of the change

* any prerequisites needed for the change (for example for interdependent changes)

* any observable changes in program behaviour (e.g. if people need to something
  in order for the patch to work)

Here is an (admittedly fictional) example:

```
bugfix: avoid segfault in somefile.cc:4711

When running the X simulation under Y conditions, it can trigger a segfault in
somefile.cc line 4711 due to a missing check on line 4707.

The patch checks the return value of strdup on line 4707, and avoids that a
null pointer is used in an out-of-memory condition, and aborts instead.

This patch depends on the config file from string patch on the
config-from-string branch.

There should be no changes in user-observable behaviour if the process does not
run out of memory.
```

Such commit messages help tremendously in the the long-term maintainability of
software. (And if you worked on something in the past, you most likely will get
asked to work on it again at some point in the future, so effort spent on
writing good commit messages will make your own life easier.)

#### 3.4.2 Push Personal Branch

You may want to remove traces of (dead end) experimentation, and maybe
clarify/santize your commit messages in your commit log by "rewriting history"
as long as you have not pushed your branch to upstream yet (please don't do
this if you've already pushed things upstream, as it'll force manual
intervention on anyone working with your branch).

You can clean up the history of the last couple of commits with a command like
```git rebase -i HEAD~20``` if you need to look at the last 20 commits.
This will open a text editor which lets you reword commits, reorder them (if
need be), or even drop some. The text editor will contain a short help on how
to do this. If it did not work out, you can always abort the rebase with ```git
rebase --abort```.

Once you're satisfied with your branch, you can push it upstream:

```
git push --set-upstream origin <yourusername>_<feature>
```

### 3.5 Merge into geant4-11.3-release-lepp

Once a feature has stabilised, and is believed to be bug-free, it can be merged back into the ```geant4-11.3-release-lepp``` branch. You should ask a couple of questions before you merge:

* Have you diverged from the main development branch (```geant4-11.3-release-lepp```)? You may want to merge the changes from ```geant4-11.3-release-lepp``` with ```git merge```, followed by a ```git rebase``` to make all of your commits happen "on top" of the ```geant4-11.3-release-lepp``` branch. Resolve conficts, if any.
* Have you run a test job to see if your feature works?
* Have you run a test job to see if everything but your feature still works?
* Have you had an experienced colleague look over the changes? (They may spot things before they become problems. A second pair of eyes is one of the most underrated techniques in this business.)
* Could you write some meaningful unit tests for your code?

The merging itself is quite easy (and should probably be done by someone who will ask the questions above):

```
git checkout geant4-11.3-release-lepp
git pull
git merge --no-ff <yourusername>_<feature>
git push origin geant4-11.3-release-lepp
```

Optional: Delete Merged Branch

```
git branch -d <yourusername>_<feature>
git push origin --delete <yourusername>_<feature>
```

---

## 4. Periodic Sync with Upstream Geant4

```
cd ~/git_repos/geant4
```

### Add the upstream remote (only needed once)

```
git remote add upstream https://github.com/Geant4/geant4.git
```

### Fetch the latest changes from the official Geant4 repository

```
git fetch upstream
```

### Merge the upstream changes into the LEPP branch

```
git checkout geant4-11.3-release-lepp
git merge upstream/geant4-11.3-release-lepp
```

### Push the updated LEPP branch

```
git push origin geant4-11.3-release-lepp
```

---

## 5. Notes / Best Practices

* Always branch for experiments; merge to geant4-11.3-release-lepp only when stable.

* Ignore build artifacts and other things that your experiments may have produced: Add examples/extended/exoticphysics/ucn/ucn_build/ to your .gitignore.

* Reproducibility: Keep a backup of the macro (.mac) and spectrum (.dat) in case they're overwritten by make.

* The apptainers/ repository laregely stays unchanged unless the container needs to be updated (for example, installing additional software by default).

* Optionally: Use the g4run wrapper instead of typing the long Apptainer path or swapping in and out of it's CLI every time.

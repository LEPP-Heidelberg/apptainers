UBUNTU_VERSION=24.04
# ROOT version used for the Geant 4 image
ROOT_BRANCH=v6-36-00-patches
ROOT_BRANCH_HASH=$(word 1,$(shell git ls-remote https://github.com/root-project/root.git $(ROOT_BRANCH)))
# default is to build against a known ROOT version as identified below; if you
# move branches or want the latest on that branch, comment out the next
# uncommented line, and take the hash from the resulting file
ROOT_BRANCH_HASH=015dbec02fec27b46a325512dd1a439d70b32ac0
GEANT4_BRANCH=geant4-11.3-release-lepp
GEANT4_BRANCH_HASH=$(word 1,$(shell git ls-remote https://github.com/LEPP-Heidelberg/geant4.git $(GEANT4_BRANCH)))
# default is to build against a known GEANT 4 version as identified below; if you
# move branches or want the latest on that branch, comment out the next
# uncommented line, and take the hash from the resulting file
# GEANT4_BRANCH_HASH=2149aef8008b2e34f79898be75d2c9d66c41f77f

# ROOT version used for the Garfield++ image (may differ from the one above)
GARFIELD_ROOT_BRANCH=v6-40-00-patches
GARFIELD_ROOT_BRANCH_HASH=$(word 1,$(shell git ls-remote https://github.com/root-project/root.git $(GARFIELD_ROOT_BRANCH)))
# default is to build against a known ROOT version as identified below (this
# is the v6-40-04 release); if you move branches or want the latest on that
# branch, comment out the next uncommented line, and take the hash from the
# resulting file
GARFIELD_ROOT_BRANCH_HASH=1211eda93010f26710eafd527d1e66921bffdf8e
GARFIELD_BRANCH=master
GARFIELD_BRANCH_HASH=$(word 1,$(shell git ls-remote https://gitlab.cern.ch/garfield/garfieldpp.git $(GARFIELD_BRANCH)))
# default is to build against a known Garfield++ version as identified below;
# if you move branches or want the latest on that branch, comment out the next
# uncommented line, and take the hash from the resulting file
GARFIELD_BRANCH_HASH=5fbb166855502adb87e436b6115c7b8ecdccf7f2

GEANT4_IMAGE=$(GEANT4_BRANCH)-root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif
GARFIELD_IMAGE=garfieldpp-$(GARFIELD_BRANCH)-root-$(GARFIELD_ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif

all: geant4 garfieldpp
geant4: $(GEANT4_IMAGE)
garfieldpp: $(GARFIELD_IMAGE)
.PHONY: all geant4 garfieldpp clean distclean

clean:
	rm -f *~
	rm -f root-*-ubuntu*.sif
distclean: clean
	rm -f root-*-ubuntu*.tar.zst geant4*.sif garfieldpp*.sif

# rules to build a ROOT image and the tarball of its /opt/root, for a given
# ROOT branch ($(1)) and commit hash ($(2))
define ROOT_RULES
.SECONDARY: root-$(2)-ubuntu$(UBUNTU_VERSION).sif
root-$(2)-ubuntu$(UBUNTU_VERSION).tar.zst: root-$(2)-ubuntu$(UBUNTU_VERSION).sif /usr/bin/apptainer
	apptainer exec $$< tar capf $$@ /opt/root
root-$(2)-ubuntu$(UBUNTU_VERSION).sif: root-ubuntu.def /usr/bin/apptainer
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		--build-arg ROOT_BRANCH=$(1) \
		--build-arg ROOT_BRANCH_HASH=$(2) $$@ $$<
endef

$(eval $(call ROOT_RULES,$(ROOT_BRANCH),$(ROOT_BRANCH_HASH)))
# only generate a second set of ROOT rules if Garfield++ uses a different ROOT
ifneq ($(GARFIELD_ROOT_BRANCH_HASH),$(ROOT_BRANCH_HASH))
$(eval $(call ROOT_RULES,$(GARFIELD_ROOT_BRANCH),$(GARFIELD_ROOT_BRANCH_HASH)))
endif

$(GEANT4_IMAGE): geant4-lepp-root-ubuntu.def root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).tar.zst
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		--build-arg ROOT_BRANCH=$(ROOT_BRANCH) \
		--build-arg ROOT_BRANCH_HASH=$(ROOT_BRANCH_HASH) \
		--build-arg GEANT4_BRANCH=$(GEANT4_BRANCH) \
		--build-arg GEANT4_BRANCH_HASH=$(GEANT4_BRANCH_HASH) \
		--mksquashfs-args="-comp zstd -Xcompression-level 19" $@ $<

$(GARFIELD_IMAGE): garfieldpp-root-ubuntu.def root-$(GARFIELD_ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).tar.zst
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		--build-arg ROOT_BRANCH=$(GARFIELD_ROOT_BRANCH) \
		--build-arg ROOT_BRANCH_HASH=$(GARFIELD_ROOT_BRANCH_HASH) \
		--build-arg GARFIELD_BRANCH=$(GARFIELD_BRANCH) \
		--build-arg GARFIELD_BRANCH_HASH=$(GARFIELD_BRANCH_HASH) \
		--mksquashfs-args="-comp zstd -Xcompression-level 19" $@ $<

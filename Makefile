UBUNTU_VERSION=24.04
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
GEANT4_BRANCH_HASH=2149aef8008b2e34f79898be75d2c9d66c41f77f



all: $(GEANT4_BRANCH)-root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif

clean:
	rm -f *~
	rm -f root-*-ubuntu*.sif
distclean: clean
	rm -f root-*-ubuntu*.tar.zst geant4*.sif

.SECONDARY: root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).sif
root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).tar.zst: root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).sif /usr/bin/apptainer
	apptainer exec $< tar capf $@ /opt/root
root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).sif: root-ubuntu.def /usr/bin/apptainer
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		--build-arg ROOT_BRANCH=$(ROOT_BRANCH) \
		--build-arg ROOT_BRANCH_HASH=$(ROOT_BRANCH_HASH) $@ $<

$(GEANT4_BRANCH)-root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif: geant4-lepp-root-ubuntu.def root-$(ROOT_BRANCH_HASH)-ubuntu$(UBUNTU_VERSION).tar.zst
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) \
		--build-arg ROOT_BRANCH=$(ROOT_BRANCH) \
		--build-arg ROOT_BRANCH_HASH=$(ROOT_BRANCH_HASH) \
		--build-arg GEANT4_BRANCH=$(GEANT4_BRANCH) \
		--build-arg GEANT4_BRANCH_HASH=$(GEANT4_BRANCH_HASH) \
		--mksquashfs-args="-comp zstd -Xcompression-level 19" $@ $<


UBUNTU_VERSION=24.04
ROOT_BRANCH=v6-36-00-patches
GEANT4_BRANCH=geant4-11.3-release-lepp

all: $(GEANT4_BRANCH)-root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif

clean:
	rm *~
	rm -f root-*-ubuntu*.sif
distclean: clean
	rm -f root-*-ubuntu*.tar.zst geant4*.sif

.SECONDARY: root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif
root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).tar.zst: root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif /usr/bin/apptainer
	apptainer exec $< tar capf $@ /opt/root
root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif: root-ubuntu.def /usr/bin/apptainer
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) --build-arg ROOT_BRANCH=$(ROOT_BRANCH) $@ $<

$(GEANT4_BRANCH)-root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif: geant4-lepp-root-ubuntu.def root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).tar.zst
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) --build-arg ROOT_BRANCH=$(ROOT_BRANCH) --build-arg GEANT4_BRANCH=$(GEANT4_BRANCH) $@ $<


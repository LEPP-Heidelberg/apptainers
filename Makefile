UBUNTU_VERSION=24.04
ROOT_BRANCH=v6-36-00-patches

all: root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).tar.zst


clean:
	rm *~
	rm -f root-*-ubuntu*.sif
distclean: clean
	rm -f root-*-ubuntu*.tar.zst

.SECONDARY: root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif
root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).tar.zst: root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif /usr/bin/apptainer
	apptainer exec $< tar capf $@ /opt/root
root-$(ROOT_BRANCH)-ubuntu$(UBUNTU_VERSION).sif: root-ubuntu.def /usr/bin/apptainer
	apptainer build --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) --build-arg ROOT_BRANCH=$(ROOT_BRANCH) $@ $<


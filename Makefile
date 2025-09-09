all: root.tar.zst


clean:
	rm *~
	rm -f root-ubuntu24.04.sif
distclean: clean
	rm -f root.tar.zst

.SECONDARY: root-ubuntu24.04.sif
root.tar.zst: root-ubuntu24.04.sif /usr/bin/apptainer
	apptainer exec root-ubuntu24.04.sif tar capf root.tar.zst /opt/root
root-ubuntu24.04.sif: root-ubuntu24.04.def /usr/bin/apptainer
	apptainer build $@ $<


# Instal OS and basic commands
FROM fedora:28
RUN dnf -y install wget &&  dnf -y install python3-numpy &&  dnf -y install wget python3-pip  && python3.6 -m pip install biopython fortranformat && python3.6 -m pip install fortranformat && yum -y clean all

# Install openmpi
#RUN dnf -y install openmpi*
#ENV PATH=$PATH:/usr/lib64/openmpi/bin


COPY ./src/ /home/ensemble-test/src/
# RUN mkdir /home/ensemble-test/results/ && yum -y clean all


# install IMP libraries
COPY ./dependences/IMP/*.rpm /tmp/IMP/
RUN dnf -y install /tmp/IMP/IMP-2.9*.rpm && \
    dnf -y install /tmp/IMP/IMP-devel*.rpm && \
    dnf -y install eigen3-devel && \
    dnf -y install make && yum -y clean all

#install MES
RUN wget http://bl1231.als.lbl.gov/pickup/mes.tar -O /tmp/mes.tar && \
    tar -xf /tmp/mes.tar -C /home/ && \
    make clean -C /home/weights/ && \
    make -C /home/weights/

#install GAJOE
# ATSAS-2.8.4-1.SUSE-42.x86_64.rpm extract to /dependences and run
COPY ./dependences/ATSAS-2.8.4-1.SUSE-42.x86_64.rpm /tmp/eom/
RUN dnf -y install /tmp/eom/ATSAS-2.8.4-1.SUSE-42.x86_64.rpm


# Prepare directory and install ensemble-fit
COPY ./saxs-ensemble-fit/ /home/ensemble-fit/
RUN make -C /home/ensemble-fit/core/ \
&& chmod u+x /home/ensemble-test/src/saxs_experiment.py \
&& chmod u+x /home/ensemble-test/src/run_script_ensemble \
&& chmod u+x /home/ensemble-test/src/make_saxs_curves.py

#Run experiment in /home/ensemble-test/src/
ENTRYPOINT [/home/ensemble-test/src/run_script_ensemble]
CMD [-d , /home/ensemble-test/foxs_curves/, -n, 10, -k, 5, -r, 3, --experimentdata, /home/ensemble-test/experimental_data/exp.dat, --output, /home/ensemble-test/results/, --preserve, --verbose, 3, --tolerance, 1]


# COPY ./examples_I/ /home/ensemble-test/examples_I/
# COPY ./examples_II/ /home/ensemble-test/examples_II/
# COPY ./experimental_data/ /home/ensemble-test/experimental_data/

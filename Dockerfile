FROM centos:8
ARG linux/amd64
ARG CONDA_VERSION="latest"
ARG CONDA_DIR="/opt/conda"

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/opt/conda/bin:$PATH"

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*

# Install some utilities
RUN dnf -y install \
	file \
	git \
	sssd-client \
	which \
	wget \
	unzip \
	vim \
	bash


RUN echo "*** install Miniconda ***" && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p "${CONDA_DIR}" && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

RUN echo "*** setup Miniconda ***" && \
    conda update --all --yes && \
    conda install -n base conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda config --set auto_update_conda False

COPY ./env/environment.yml .

RUN echo "*** setup conda env ***" && \
    conda env create -n startanalytics_2025 --file environment.yml && \
    echo "conda activate startanalytics_2025" >> ~/.bashrc && \
    rm environment.yml


RUN mkdir -p /opt/notebooks
ADD  ./notebooks /opt/

WORKDIR /opt/notebooks


SHELL ["conda", "run", "-n", "startanalytics_2025", "/bin/bash", "-c"]

# Register IRkernel with Jupyter
RUN R -e "IRkernel::installspec(user = FALSE)"

# Install additional R packages if needed
# RUN R -e "install.packages(c('ggplot2', 'dplyr', 'tidyverse'), repos='https://cran.r-project.org')"

# Set the Conda environment as default
ENV CONDA_DEFAULT_ENV=startanalytics_2025

# Expose port for JupyterLab

RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_origin = '*'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py

EXPOSE 8888
CMD ["conda", "run", "-n", "startanalytics_2025", "jupyter-lab", "--config=/root/.jupyter/jupyter_notebook_config.py"]

# CMD ["conda", "run", "-n", "startanalytics_2025", "jupyter-lab", "--ip=0.0.0.0", "--no-browser", "--allow-root"]
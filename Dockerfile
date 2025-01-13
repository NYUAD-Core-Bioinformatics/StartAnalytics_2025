FROM continuumio/miniconda3:latest

ARG CONDA_DIR="/opt/conda"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/opt/conda/bin:$PATH"

RUN conda install -y mamba -n base -c conda-forge 

COPY ./env/environment.yml .

RUN echo "*** Setting up Conda environment ***" && \
    mamba env create -n startanalytics_2025 --file environment.yml && \
    echo "conda activate startanalytics_2025" >> ~/.bashrc && \
    conda clean -afy && \
    rm environment.yml

RUN conda run -n startanalytics_2025 R -e "IRkernel::installspec(user = FALSE)"

ADD ./notebooks /opt/notebooks
ADD ./notebooks/data /opt/notebooks/data

WORKDIR /opt/notebooks
EXPOSE 8888

SHELL ["conda", "run", "-n", "startanalytics_2025", "/bin/bash", "-c"]
CMD ["conda", "run", "-n", "startanalytics_2025", "jupyter-lab", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''", "--no-browser"]

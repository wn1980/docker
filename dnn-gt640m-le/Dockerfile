FROM nvidia/cuda:8.0-cudnn7-devel

ARG PYTHON_VERSION=3.6

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*

# install Miniconda3
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh 

# set environment path
ENV PATH /opt/conda/bin:$PATH
ENV PATH /usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# install basic Python packages
RUN conda install -y python=$PYTHON_VERSION

# install jupyter
RUN conda install -y -c conda-forge jupyterlab

# conda clean
RUN conda clean -ya

# install TensorFlow GPU & Keras
RUN pip install tensorflow-gpu==1.4.0 
RUN pip install keras

# install Pytorch & Torchvision
RUN pip install torch==0.3.1 -f https://download.pytorch.org/whl/cu80/stable
RUN pip install torchvision==0.2.1

# working dir
RUN mkdir -p /home/works && chmod 1777 /home/works

ENV HOME /home/works

# jupyter port
EXPOSE 8888

# fix symbolic link
RUN ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so /usr/lib/x86_64-linux-gnu/libcudnn.so.6

# finally, start up JupyterLab
COPY startup.sh /

COPY check-gpu.ipynb $HOME

RUN chmod a+x startup.sh

CMD ["/startup.sh"]

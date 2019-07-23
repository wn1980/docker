FROM nvidia/cuda:8.0-cudnn6-devel

ARG PYTHON_VERSION=3.5
ARG MINICONDA_SH=https://repo.anaconda.com/miniconda/Miniconda3-4.2.11-Linux-x86_64.sh

#ARG PYTHON_VERSION=3.6
#ARG MINICONDA_SH=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
         sudo \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev && \
     rm -rf /var/lib/apt/lists/*

# install Miniconda3
RUN curl -o ~/miniconda.sh -O $MINICONDA_SH && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh 

# set environment path
ENV PATH /opt/conda/bin:$PATH

ENV PATH /usr/local/cuda/bin:$PATH

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# fix symbolic link for cuDNN 7.x
#RUN ln -s /usr/lib/x86_64-linux-gnu/libcudnn.so /usr/lib/x86_64-linux-gnu/libcudnn.so.6

# install basic Python packages
RUN conda install -y python=$PYTHON_VERSION

# install jupyter lab
RUN conda install -y -c conda-forge jupyterlab=0.34.12

# install TensorFlow GPU & Keras
RUN pip install tensorflow-gpu==1.4.0 

RUN pip install keras

# install Pytorch & Torchvision
RUN pip install torch==0.3.1 -f https://download.pytorch.org/whl/cu80/stable

RUN pip install torchvision==0.2.2

# clean
RUN conda clean -ya
RUN apt -y autoremove

# working dir
#RUN mkdir -p /home/works && chmod 1777 /home/works

# Configure user
ARG user=jupyter
ARG passwd=jupyter
ARG uid=1000
ARG gid=1000
ENV USER=$user
ENV PASSWD=$passwd
ENV UID=$uid
ENV GID=$gid
RUN groupadd $USER && \
    useradd --create-home --no-log-init -g $USER $USER && \
    usermod -aG sudo $USER && \
    echo "$PASSWD:$PASSWD" | chpasswd && \
    chsh -s /bin/bash $USER && \
    # Replace 1000 with your user/group id
    usermod  --uid $UID $USER && \
    groupmod --gid $GID $USER

# jupyter port
EXPOSE 8888

# finally, start up JupyterLab
ENV HOME /home/$user

RUN chmod 1777 $HOME

COPY startup.sh /

COPY check-gpu.ipynb $HOME

RUN chmod a+x startup.sh

USER $USER

CMD ["/startup.sh"]

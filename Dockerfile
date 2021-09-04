FROM ubuntu:20.04

ARG OPENCV_VERSION=4.5.3
ARG ONNXRUNTIME_VERSION=1.8.2
ARG CMALE_VERSION=3.21.1
ARG NUM_JOBS=8

ENV DEBIAN_FRONTEND noninteractive

# Install package dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	software-properties-common \
	autoconf \
	automake \
	libtool \
	pkg-config \
	ca-certificates \
	wget \
	git \
	curl \
	libjpeg-dev \
	libpng-dev \
	language-pack-en \
	locales \
	locales-all \
	python3 \
	python3-py \
	python3-dev \
	python3-pip \
	python3-numpy \
	python3-pytest \
	python3-setuptools \
	libprotobuf-dev \
	protobuf-compiler \
	zlib1g-dev \
	swig \
	vim \
	gdb \
	valgrind \
	libsm6 \
	libxext6 \
	libxrender-dev \
	cmake \
	unzip
RUN apt-get clean

RUN cd /usr/local/bin && \
	ln -s /usr/bin/python3 python && \
	ln -s /usr/bin/pip3 pip && \
	pip install --upgrade pip setuptools wheel

# System locale
# Important for UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install CMake
RUN cd /tmp && \
	wget https://github.com/Kitware/CMake/releases/download/v${CMALE_VERSION}/cmake-${CMALE_VERSION}-linux-x86_64.sh && \
	bash cmake-${CMALE_VERSION}-linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license
RUN rm -rf /tmp/*

# Install OpenCV
# OpenCV-Python dependencies
RUN apt-get update && apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
RUN apt-get update && apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
RUN apt-get update && apt-get install -y libgtk-3-dev 
RUN apt-get update && apt-get install -y libpng-dev libopenexr-dev libtiff-dev libwebp-dev

RUN cd /tmp && \
	wget -O opencv.zip https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
	wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
	unzip opencv.zip && \
	unzip opencv_contrib.zip && \
	mkdir -p build && cd build && \
	cmake -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${OPENCV_VERSION}/modules \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_LIST=core,highgui,improc,dnn \
	-DBUILD_PNG=OFF \
	-DBUILD_TIFF=OFF \
	-DBUILD_TBB=OFF \
	-DBUILD_JPEG=OFF \
	-DBUILD_JASPER=OFF \
	-DBUILD_ZLIB=OFF \
	-DBUILD_JAVA=OFF \
	-DBUILD_opencv_python2=OFF \
	-DBUILD_opencv_python3=ON \
	-DWITH_OPENCL=OFF \
	-DWITH_OPENMP=OFF \
	-DWITH_FFMPEG=ON \
	-DWITH_GSTREAMER=OFF \
	-DWITH_GSTREAMER_0_10=OFF \
	-DWITH_CUDA=OFF \
	-DWITH_GTK=ON \
	-DWITH_VTK=OFF \
	-DWITH_TBB=ON \
	-DWITH_1394=OFF \
	-DWITH_OPENEXR=OFF \
	-DINSTALL_C_EXAMPLES=ON \
	-DINSTALL_TESTS=OFF  \
	../opencv-${OPENCV_VERSION} &&\
	cmake --build . --parallel ${NUM_JOBS} && \
	make install
RUN rm -rf /tmp/*

# Install ONNX Runtime
RUN pip install pytest==6.2.1 onnx==1.10.1

RUN wget https://github.com/microsoft/onnxruntime/releases/download/v1.4.0/onnxruntime-linux-x64-1.4.0.tgz && \
	tar -xvf onnxruntime-linux-x64-1.4.0.tgz && \
	rm onnxruntime-linux-x64-1.4.0.tgz && \
	mv onnxruntime-linux-x64-1.4.0 /usr/local/onnxruntime && \
	cp -r /usr/local/onnxruntime/lib/* /usr/local/lib/

RUN cd /tmp && wget https://github.com/dpilger26/NumCpp/archive/refs/tags/Version_2.5.0.zip && \
	unzip Version_2.5.0.zip && rm Version_2.5.0.zip && \
	cd NumCpp-Version_2.5.0 && \
	mkdir build && cd build && \
	cmake .. && cmake --build . --parallel ${NUM_JOBS} --target install

RUN rm -rf /tmp/*

RUN apt-get update && apt-get install -y --no-install-recommends \
	libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev

WORKDIR /srcfd_cpp

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	#
	# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

CMD ["/bin/bash"]
#
# PX4 ROS development environment
#

FROM px4io/px4-dev-ros2-foxy:2020-11-18
LABEL maintainer="Jinwoo Oh <ojw0306@naver.com>"
######################################################
## CUDA + OPENGL 설치
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.0.3

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-0=11.0.221-1 \
    cuda-compat-11-0 \
    && ln -s cuda-11.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

RUN apt-get update && apt-get install -y --no-install-recommends \
	software-properties-common \
        pkg-config \
        libglvnd-dev libglvnd-dev:amd64 \
        libgl1-mesa-dev libgl1-mesa-dev:amd64 \
        libegl1-mesa-dev libegl1-mesa-dev:amd64 \
        libgles2-mesa-dev libgles2-mesa-dev:amd64 && \
    rm -rf /var/lib/apt/lists/*


######################################################

######################################################
## 유용한 오픈소스 소프트웨어 설치
RUN	add-apt-repository ppa:linuxuprising/shutter \
	&& apt-get update && apt-get upgrade -y \ 
	&& DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata \	
	&& DEBIAN_FRONTEND="noninteractive" apt-get -y install keyboard-configuration \
	&& apt-get install -y net-tools \
   	&& apt-get install -y vim \
	&& apt-get install -y software-properties-common \
	&& apt-get install -y nvidia-driver-450 \
	&& apt-get install -y locales

RUN sudo add-apt-repository ppa:linuxuprising/shutter
RUN sudo apt-get update && apt-get upgrade -y
RUN sudo apt-get install -y \
  		build-essential \
		  cmake \
		  curl \
		  gimp \
		  git \
		  gnupg2 \
		  gparted \
		  htop \
		  iftop \
		  iperf \
		  kdenlive \
		  kolourpaint \
		  lsb-release \
		  mc \
		  ntpdate \
		  okular \
		  qtcreator \
		  shutter \
		  simplescreenrecorder \
		  terminator \
		  tig \
		  tmux \
		  vim \
		  vlc \
		  wget \
		  xclip

RUN sudo pip3 install -U setuptools

## ROS2 Foxy 설치
RUN sudo apt-get -y install -y locales \ 
		&& sudo locale-gen en_US en_US.UTF-8 \	
		&& sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
		&& export LANG=en_US.UTF-8 \
		&& sudo apt update && sudo apt install curl gnupg2 lsb-release \
		&& curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
		&& sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu focal main" > /etc/apt/sources.list.d/ros2-latest.list' \
		&& sudo apt update \
		&& sudo apt install -y ros-foxy-desktop ros-foxy-rmw-cyclonedds-cpp \
		&& sudo apt install python3-argcomplete


RUN mkdir -p /root/robot_ws/src 


########################################################################
## ROS 단축어, bashrc 설정
RUN 	echo "alias cw='cd /root/robot_ws'" >> ~/.bashrc \
	&& echo "alias cbp='colcon build --symlink-install --packages-select'" >>  ~/.bashrc \
	&& echo "alias sb='source ~/.bashrc'" >> ~/.bashrc \
	&& echo "alias sls='source /root/robot_ws/install/local_setup.bash'" >>  ~/.bashrc \
	&& echo "alias vr='vim ~/.bashrc'" >>  ~/.bashrc \
	&& echo "alias nr='nano ~/.bashrc'" >>  ~/.bashrc \
	&& echo "alias sr='source ~/.bashrc'" >>  ~/.bashrc \
	&& echo "alias killgazebo='killall -9 gazebo & killall -9 gzserver  & killall -9 gzclient'" >>  ~/.bashrc \

	&& echo "alias cw='cd ~/robot_ws'" >>  ~/.bashrc \
	&& echo "alias cs='cd ~/robot_ws/src'" >>  ~/.bashrc \

	&& echo "alias cb='cd ~/robot_ws && colcon build --symlink-install'" >>  ~/.bashrc \
	&& echo "alias cbp='cd ~/robot_ws && colcon build --symlink-install --packages-select'" >>  ~/.bashrc \

	&& echo "alias rt='ros2 topic list'" >>  ~/.bashrc \
	&& echo "alias re='ros2 topic echo'" >>  ~/.bashrc \
	&& echo "alias rn='ros2 node list'" >>  ~/.bashrc \
	&& echo "alias af='ament_flake8'" >>  ~/.bashrc \
	&& echo "alias ac='ament_cpplint'" >>  ~/.bashrc \

	&& echo "alias testpub='ros2 run demo_nodes_cpp talker'" >>  ~/.bashrc \
	&& echo "alias testsub='ros2 run demo_nodes_cpp listener'" >>  ~/.bashrc \
	&& echo "alias testpubimg='ros2 run image_tools cam2image'" >>  ~/.bashrc \
	&& echo "alias testsubimg='ros2 run image_tools showimage'" >>  ~/.bashrc \

	&& echo "alias ros2_init='. /opt/ros/foxy/setup.bash'" >>  ~/.bashrc \
	&& echo "alias all_init='. ~/robot_ws/install/local_setup.bash'" >>  ~/.bashrc \

	&& echo "export ROS_DOMAIN_ID=10" >>  ~/.bashrc \

	&& echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >>  ~/.bashrc \
	# export RMW_IMPLEMENTATION=rmw_fastrtps_cpp 

	# export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity} {time}] [{name}]: {message} ({function_name}() at {file_name}:{line_number})'
	&& echo "export RCUTILS_CONSOLE_OUTPUT_FORMAT='[{severity}] [{time}]: {message}'" >>  ~/.bashrc \
	&& echo "export RCUTILS_COLORIZED_OUTPUT=1" >>  ~/.bashrc \
	# export RCUTILS_LOGGING_USE_STDOUT=1 
	&& echo "export RCUTILS_LOGGING_BUFFERED_STREAM=1" >>  ~/.bashrc \

	&& echo "source /opt/ros/foxy/setup.bash" >>  ~/.bashrc \
	&& echo "source /opt/ros/noetic/local_setup.bash" >> ~/.bashrc \
	&& echo "source ~/robot_ws/install/local_setup.bash" >>  ~/.bashrc \
	&& echo "source ~/catkin_ws/install/local_setup.bash" >>  ~/.bashrc




##########################################################
## ROS Neotic 설치
RUN 	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
	&& sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
	&& sudo apt update -y \
	&& sudo apt install -y ros-noetic-desktop-full \
	&&  /bin/bash -c "source /opt/ros/noetic/setup.bash"

RUN 	mkdir -p ~/catkin_ws/src \
	&& cd ~/catkin_ws



## PX4+ROS를 위한 패키지 설치(FastRTPS)

RUN 	mkdir -p /root/git_ws/
WORKDIR /root/git_ws
RUN	git clone https://github.com/oraeng/DevEnv_File.git
WORKDIR /root/git_ws/DevEnv_File
RUN	bash PX4_Install.sh


WORKDIR /root/
RUN	git clone https://github.com/PX4/PX4-Autopilot.git /root/PX4_ws













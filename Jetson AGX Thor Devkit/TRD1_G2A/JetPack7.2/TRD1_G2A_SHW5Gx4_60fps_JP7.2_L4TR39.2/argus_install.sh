sudo apt-get update
sudo apt-get install nvidia-l4t-jetson-multimedia-api
cd /usr/src/jetson_multimedia_api/argus/

#安装依赖
sudo apt-get install cmake build-essential pkg-config libx11-dev libgtk-3-dev libexpat1-dev libjpeg-dev libgstreamer1.0-dev

sudo mkdir build && cd build
#编译安装
sudo cmake ..
sudo make -j8
sudo make install
# http://bioinfo.mpipz.mpg.de/shoremap/installation.html

mkdir software
mkdir src
cd src
# Check if libXm.so* and libXt.so* installed 
sudo apt-get install apt-file
apt-file update
apt-file search libXm.so
apt-file search libXt.so

# If not, install
# https://askubuntu.com/questions/772739/unable-to-install-libmotif4
wget http://launchpadlibrarian.net/207968936/libmotif4_2.3.4-8ubuntu1_amd64.deb
sudo dpkg -i libmotif4_2.3.4-8ubuntu1_amd64.deb
sudo apt-get install libxt-dev

# Download and Installation of library DISLIN
wget ftp://ftp.gwdg.de/pub/grafik/dislin/linux/i586_64/dislin-11.0.linux.i586_64.deb
sudo dpkg -i dislin-11.0.linux.i586_64.deb 
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/dislin' >> ~/.bashrc

# Download and Installation of SHOREmap v3.x
mkdir SHOREmap_v3.6
cd SHOREmap_v3.6
wget http://bioinfo.mpipz.mpg.de/shoremap/SHOREmap_v3.6.tar.gz
tar xzvf SHOREmap_v3.6.tar.gz 
make
mv SHOREmap ../../software
cd ..
rm -rf SHOREmap_v3.6

## Install SHORE
#wget http://archive.ubuntu.com/ubuntu/pool/main/b/boost1.58/libboost-thread1.58.0_1.58.0+dfsg-5ubuntu3.1_amd64.deb
#sudo dpkg -i libboost-thread1.58.0_1.58.0+dfsg-5ubuntu3.1_amd64.deb
#sudo apt install aptitude
#sudo aptitude install libboost-all-dev
#sudo apt-get install -y libgsl0-dev zlib1g-dev liblzma-dev 
## install gsl from source
#wget http://mirrors.ustc.edu.cn/gnu/gsl/gsl-1.11.tar.gz
#tar xzvf gsl-1.11.tar.gz
#cd gsl-1.11
#./configure --prefix=/home/xfu/Git/SHOREmapping/software
#make
#make install
#cd ..
#wget https://netix.dl.sourceforge.net/project/shore/Release_0.9/shore-0.9.3.tar.gz
#tar xzf shore-0.9.3.tar.gz
#cd shore-0.9.3/
#export CPLUS_INCLUDE_PATH=/home/xfu/Git/SHOREmapping/software/include
#export LIBRARY_PATH=/home/xfu/Git/SHOREmapping/software/lib
#export LD_LIBRARY_PATH=/home/xfu/Git/SHOREmapping/software/lib
#./configure --prefix=/home/xfu/Git/SHOREmapping/software
#make
#make install

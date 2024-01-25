apt-get update
apt-get install -y libssl-dev
apt-get install -y software-properties-common
#apt-get install -y python-software-properties
add-apt-repository -y ppa:ubuntu-toolchain-r/test
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -
add-apt-repository -y 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-4.0 main'
apt-get install -y build-essential gcc g++ clang lldb lld gdb
apt-get install -y git  flex bison libnuma-dev
apt-get install -y dstat
apt-get install -y vim htop
apt-get install -y vagrant curl
apt install -y libjemalloc-dev
apt install -y openjdk-8-jre-headless
apt install -y cgroup-tools
apt install -y python3-pip
apt install -y numactl
pip3 install --upgrade pip
pip3 install pandas
echo "set tabstop=4" > ~/.vimrc

# set up cmake
mkdir -p /home/cmake
cd /home/cmake
wget https://cmake.org/files/v3.19/cmake-3.19.1-Linux-x86_64.sh
bash cmake-3.19.1-Linux-x86_64.sh --prefix=/usr --skip-license --exclude-subdir

# setup git
#git config --global user.name "ScarletGuo"
#git config --global user.email "zguo74@wisc.edu"

# set up redis
cd
git clone https://github.com/redis/redis.git
cd redis
make -j4
cp /home/Cornus/tools/redis.conf ./
cd
mkdir redis_data/

# set up ssh key
#bash
#(echo ; echo ; echo ; echo ; echo ; echo ;echo ; echo ; echo ; echo ;) | ssh-keygen -t ed25519 -C "zguo74@wisc.edu"
#eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_ed25519

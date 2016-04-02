####### Script to Install Shadowsocks-go MU #######

# Check Root
if [ $UID != 0 ]; then
	echo "I need root"
	exit 1
fi

# Pre-Set
read -p "Yout mu address:" muaddr
read -p "Your mu key:" mukey
read -p "Node ID:" nodeid
echo -e "\n\033[32m===============Installtion start================\033[0m\n"

# Install envs and supervisor
echo -e "\033[32mInstalling envs\033[0m"
(yum -y install git gcc make wget openssl screen python-setuptools && easy_install supervisor) >/dev/null

# Install Golang
echo -e "\033[32mInstalling Golang\033[0m"
cd && wget https://storage.googleapis.com/golang/go1.6.linux-386.tar.gz -o/dev/null --no-check-certificate && \
tar -zxf go1.6.linux-386.tar.gz -C /usr/local
export PATH=$PATH:/usr/local/go/bin

# Install Shadowsocks-go
echo -e "\033[32mInstalling Shadowsocks-go\033[0m"
git clone https://github.com/orvice/shadowsocks-go.git &>/dev/null
export GOPATH=/root/shadowsocks-go
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server >/dev/null
git clone https://github.com/go-redis/redis.git ~/shadowsocks-go/src/gopkg.in/redis.v3 &>/dev/null
git clone https://github.com/bsm/ratelimit.git ~/shadowsocks-go/src/gopkg.in/bsm/ratelimit.v1 &>/dev/null
cd ~/shadowsocks-go/mu
go get &>/dev/null
go build
cp example.conf config.conf
sed -i "s|url http://sspanel.dev/mu|url $muaddr|" config.conf
sed -i "s/key key/key $mukey/" config.conf
sed -i "s/node_id 1/node_id $nodeid/" config.conf
sed -i "s/pass/#pass/" config.conf

# Install Redis
echo -e "\033[32mInstalling Redis\033[0m"
cd && wget http://download.redis.io/releases/redis-3.0.7.tar.gz -o/dev/null  && tar -zxf redis-3.0.7.tar.gz && cd redis-3.0.7 && make MALLOC=libc &>/tmp/redisbuild.log
wget --no-check-certificate -O ~/redis-3.0.7/redis.conf -o/dev/null https://raw.githubusercontent.com/popu125/install_ss_go_mu/master/redis.conf >/dev/null

# Set Supervisor
echo -e "\033[32mSetting Supervisor\033[0m"
wget --no-check-certificate -O /etc/supervisord.conf -o/dev/null https://raw.githubusercontent.com/popu125/install_ss_go_mu/master/supervisord.conf >/dev/null
touch ~/ssgo.log
sed -i '$ i/root/redis-3.0.7/src/redis-server /root/redis-3.0.7/redis.conf' /etc/rc.local
sed -i '$ i\/usr\/bin\/supervisord -c \/etc\/supervisord.conf' /etc/rc.local


# Almost complate
service iptables stop >/dev/null
if [ ! -f "/root/shadowsocks-go/mu/mu" -o ! -f "/root/redis-3.0.7/src/redis-server" -o ! -f "/usr/bin/supervisord" ]; then
	echo -e "\033[32m\n===============Installtion error================\n\nRedis compilation log is in /tmp/redisbuild.log\033[0m"
	exit 1
fi

/root/redis-3.0.7/src/redis-server /root/redis-3.0.7/redis.conf
/usr/bin/supervisord -c /etc/supervisord.conf
echo -e "\033[32m\n=============Installtion complated==============\n\033[0m"


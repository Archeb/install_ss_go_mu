####### Script to Install Shadowsocks-go MU #######

# Check Root
if [ $UID != 0 ]; then
	echo "I need root"
	exit 1
fi

# Pre-Set
read -p "Yout mu address:" muaddr
read -p "Your mu key:" mukey
printf "\n===============Installtion start================\n\n"

# Install envs and supervisor
echo "Installing envs"
(yum -y install git gcc make wget openssl screen python-setuptools && easy_install supervisor) >/dev/null

# Install Golang
echo "Installing Golang"
(cd && wget https://storage.googleapis.com/golang/go1.6.linux-386.tar.gz --no-check-certificate && \
tar -zxf go1.6.linux-386.tar.gz -C /usr/local) >/dev/null
export PATH=$PATH:/usr/local/go/bin

# Install Shadowsocks-go
echo "Installing Shadowsocks-go"
(git clone https://github.com/orvice/shadowsocks-go.git >/dev/null
export GOPATH=/root/shadowsocks-go
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server >/dev/null
git clone https://github.com/go-redis/redis.git ~/shadowsocks-go/src/gopkg.in/redis.v3
git clone https://github.com/bsm/ratelimit.git ~/shadowsocks-go/src/gopkg.in/bsm/ratelimit.v1
cd ~/shadowsocks-go/mu
go get && go build
cp example.conf config.conf
sed "s/url http:\/\/sspanel.dev\/mu/url $muaddr/" config.conf
sed -i "s/key key/key $mukey/" config.conf
sed -i "s/pass/#pass/" config.conf) >/dev/null

# Install Redis
echo "Installing Redis"
(cd && wget http://download.redis.io/releases/redis-3.0.7.tar.gz && tar -zxf redis-3.0.7.tar.gz && cd redis-3.0.7 && make MALLOC=libc) >/dev/null
wget -N --no-check-certificate -O ~/redis-3.0.7/redis.conf https://raw.githubusercontent.com/popu125/install_ss_go_mu/master/redis.conf >/dev/null

# Set Supervisor
echo "Setting Supervisor"
wget -N --no-check-certificate -O /etc/supervisor.conf https://raw.githubusercontent.com/popu125/install_ss_go_mu/master/supervisor.conf >/dev/null
touch ~/ssgo.log
sed -i '$ i\/usr\/bin\/supervisord -c \/etc\/supervisord.conf' /etc/rc.local


# Almost complate
service iptables stop
if [ ! -f "~/shadowsocks-go/mu/mu" -o ! -f "/root/redis-3.0.7/src/redis-server" -o ! -f "/usr/bin/supervisord" ]; then
	printf "\n===============Installtion error================\n\n"
	exit 1
fi

printf "\n=============Installtion complated==============\n\n"


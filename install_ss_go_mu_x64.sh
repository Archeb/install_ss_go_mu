yum -y install git
yum -y install wget
cd /root/
wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz --no-check-certificate
tar -zxvf go1.6.linux-amd64.tar.gz -C /usr/local
export PATH=$PATH:/usr/local/go/bin
git clone https://github.com/orvice/shadowsocks-go.git
export GOPATH=/root/shadowsocks-go
go get github.com/shadowsocks/shadowsocks-go/cmd/shadowsocks-server
git clone https://github.com/go-redis/redis.git /root/shadowsocks-go/src/gopkg.in/redis.v3
git clone https://github.com/bsm/ratelimit.git /root/shadowsocks-go/src/gopkg.in/bsm/ratelimit.v1
cd /root/shadowsocks-go/mu
go get
go build
cd /root/
wget http://download.redis.io/releases/redis-3.0.7.tar.gz
tar -zxvf redis-3.0.7.tar.gz
cd redis-3.0.7
yum -y install gcc
yum -y install make
make MALLOC=libc
wget -N https://raw.githubusercontent.com/Archeb/install_ss_go_mu/master/redis.conf 
src/redis-server /root/redis-3.0.7/redis.conf
cd /root/shadowsocks-go/mu
cp example.conf config.conf
yum -y install screen
service iptables stop
echo Basic configuration completed, please follow the article for the next step.
echo 基础配置完成，请看文章进行下一步

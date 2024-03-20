使用confluent kafka 与 flink 为核心搭建 --鞍钢集团数据总线


简介：数据总线 核心分为数据采集kafka和计算处理flink
核心组件 zookeeper kafka schema-registery kafka-connect flink
监控组件 kafdrop konw-streaming streampark

搭建顺序 zookeeper-》kafka-》schema-registery-》kafdrop-》kafka-connect-》konw-streaming-》flink-》streampark
-----------------------配置ip host-------------------------
10.151.47.125 10.151.47.126 10.151.47.127 10.151.47.31  三台kafka服务器 1台know-streaming 服务器

10.151.47.125 10.151.47.126 10.151.47.127  
vim  /etc/hosts
192.168.71.147 ldp-kafka-1-2
192.168.71.176 ldp-kafka-1-3
192.168.71.96 ldp-kafka-1-4

10.151.47.31
远程监控kafka集群
vim  /etc/hosts
192.168.71.147 ldp-kafka-1-2
192.168.71.176 ldp-kafka-1-3
192.168.71.96 ldp-kafka-1-4

127.0.0.1 meta1-dameng elasticsearch-single knowstreaming-manager knowstreaming-mysql  docker 启动know-streaming


-----------------------准备工作创建目录-------------------------
################################################################################
下载kafdrop-3.29.0.jar和confluent-community-7.0.1.tar
cd / ;
mkdir app;
chmod 755 app;
################################################################################
cd /app;mkdir kafka;
cd /app/kafka;mkdir -p data/kafka;mkdir -p data/zookeeper;mkdir -p data/schema-registry
cd /opt ;
mkdir kafdrop;
chmod 755 kafdrop;
################################################################################
cd kafdrop;
chmod 644 kafdrop-3.29.0.jar 
################################################################################
cp confluent-7.0.1.tar.gz /app/kafka
tar -vxf confluent-community-7.0.1.tar

cp kafdrop-3.29.0.jar /opt/kafdrop;cd /opt/kafdrop chmod +755 kafdrop-3.29.0.jar
###########################kafka connect插件目录#####################################################
mkdir /app/kafka/connect/

scp -r /app/kafka/connect/* root@10.151.47.125:/app/kafka/connect/
scp -r /app/kafka/connect/* root@10.151.47.126:/app/kafka/connect/
scp -r /app/kafka/connect/* root@10.151.47.127:/app/kafka/connect/
----------------------------------------------------------------
三个机器分别执行 
cat >> data/zookeeper/myid <<- EOF
1
EOF

cat >> data/zookeeper/myid <<- EOF
2
EOF

cat >> data/zookeeper/myid <<- EOF
3
EOF
-----------------------搭建核心组件-------------------------
confluent-community-7.0.1.tar  采用 confluent-community-7.0.1

解压至 /app/kafka/confluent-7.0.1

-----------------------搭建核心组件zookeeper-------------------
1.zookeeper搭建
三个机器分别
修改zookeeper.properties
cd /etc/systemd/system
vim zookeeper.service
systemctl
三个机器分别
systemctl start zookeeper.service
开机自启动
systemctl enable zookeeper.service
systemctl stop zookeeper.service
日志
journalctl -f -u zookeeper

systemctl enable rocketmq-dashboard.service
-----------------------搭建核心组件kafka----------------------
2.kafka搭建

修改server.properties
cd /etc/systemd/system
vim kafka.service

三个机器分别
systemctl start kafka
systemctl restart kafka
自启动
systemctl enable kafka.service
systemctl stop kafka.service
日志
journalctl -f -u kafka
-----------------------搭建核心组件schema-registery-----------
3.schema-registery搭建
单机部署schema-registery
cd /app/kafka/confluent-7.0.1/etc/schema-registry
修改
schema-registery.properties
connect-avro-distributed.properties

cd /etc/systemd/system
vim schema-registery.service

systemctl start schema-registry.service
systemctl stop schema-registry.service
自启动
systemctl enable schema-registry.service
-----------------------搭建组件kafdrop-----------------------
4.搭建 kafdrop

cd /etc/systemd/system
vim kafdrop.service

systemctl start kafdrop.service
systemctl enable kafdrop.service
-----------------------搭建核心组件kafka-connect--------------
5.kafka-connect搭建
采用集群部署connect
修改
connect-distributed.properties
cd /etc/systemd/system
vim connect-distributed.service
systemctl start connect-distributed.service
systemctl enable connect-distributed.service
systemctl stop connect-distributed.service
journalctl -f -u connect-distributed
-----------------------搭建组件konw-streaming-------------------------
6.konw-streaming 监控kafka集群 使用docker
先安装docker

docker compose up -d 



-----------------------搭建监控组件-------------------------
麒麟系统的依赖
cd /root/docker/

本地yum安装 
yum localinstall *.rpm
---------------------------------


1.know-streaming 监控kafka集群

cp 文件docker-compose.yaml等文件到本地

目录 /app/docker/know_streaming


 volumes:
      - /ks/manage/log:/logs
查看docker-compose.yaml文件中的映射路径进行修改和创建 ,并且对路径修改权限
例如  mkdir  /ks/manage/log  chmod 777 ./* 


docker compose up -d 启动容器编排

--------------------------docker常用命令-------------------------------------

docker compose stop       #暂定所有容器

docker compose rm --stop  #删除停掉的容器

docker compose up -d      #启动文件配置的容器

docker compose start      #启动容器

docker compose restart    #重启容器 

docker logs -f --tail=300 容器id  #查看容器日志

---------------------------------------------------------------
登陆操作界面 默认密码 admin/admin 对弱密码进行修改
配置集群
anst-cluster

10.151.47.125:9092,10.151.47.126:9092,10.151.47.127:9092

192.168.71.147:2181,192.168.71.176:2181,192.168.71.96:2181

JMX Port 9097 version 3.0.0

connect 3.3.0


--------------------------安装flink和streampark-------------------------------------
查看flink standalone集群配置和streampark配置文档

journalctl -f -u zookeeper

journalctl -f -u schema-registry
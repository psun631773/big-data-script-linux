flink-standalone集群配置
10.151.34.233     master  jobmanager
10.151.34.234    worker
10.151.34.235    worker
三台服务器配置flink集群
1免密登陆
ssh-keygen -t rsa
10.151.34.233    root   qw!KK.UIkarF7033
10.151.34.234    root   qw!KK.UIkarG7034
10.151.34.235    root   qw!KK.UIkarH7035
ssh-copy-id -i ~/.ssh/id_rsa.pub 10.151.34.233
ssh-copy-id -i ~/.ssh/id_rsa.pub 10.151.34.234
ssh-copy-id -i ~/.ssh/id_rsa.pub 10.151.34.235
ssh 10.151.34.233
ssh 10.151.34.234
ssh 10.151.34.235

2修改配置文件flink-conf.yaml jobManger
jobmanager.rpc.address: 10.151.34.233     jobManger
taskmanager.numberOfTaskSlots: 4           四个槽位
env.java.home: /app/jdk-11.0.19               添加javahome远程ssh代码调用使用的

2修改启动文件
config.sh 

DEFAULT_ENV_PID_DIR="/app/flink-1.13.3/tmp"                          # Directory to store *.pid files to
3分发flink文件
scp -r /app/flink-1.13.3 root@10.151.34.234:/app/flink-1.13.3
scp -r /app/flink-1.13.3 root@10.151.34.235:/app/flink-1.13.3





4.启动集群
cd /app/flink-1.13.3/bin
./start-cluster.sh
http://10.151.34.233:8081/#/overview




cd /app/flink-1.13.3/conf
vim flink-conf.yaml
添加配置
env.java.home: /app/jdk1.8.0_161

5.使用systemd
开机自启动
vim /etc/systemd/system/flink.service


[Unit]
Description=Flink JobManager

[Service]
ExecStart=/app/flink-1.13.3/bin/start-cluster.sh
ExecStop=/app/flink-1.13.3/bin/stop-cluster.sh

[Install]
WantedBy=multi-user.target


systemctl daemon-reload
systemctl enable flink
systemctl start flink
systemctl status flink


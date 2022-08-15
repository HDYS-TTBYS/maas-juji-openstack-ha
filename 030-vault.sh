juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel 1.7/stable --config vip=192.168.1.208 vault

juju deploy /home/hdys/openstack/charms/charm-hacluster vault-hacluster --config cluster_count=3
juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 etcd
juju deploy --to lxd:0 cs:~containers/easyrsa

juju add-relation vault:ha vault-hacluster:ha
juju add-relation etcd:db vault:etcd
juju add-relation etcd:certificates easyrsa:client

juju deploy --channel 8.0/stable mysql-router vault-mysql-router
juju add-relation vault-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation vault-mysql-router:shared-db vault:shared-db

juju add-relation mysql-innodb-cluster:certificates vault:certificates

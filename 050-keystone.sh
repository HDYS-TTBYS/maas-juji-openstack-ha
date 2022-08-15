juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 050-keystone.yaml keystone

juju deploy --channel 8.0/stable mysql-router keystone-mysql-router
juju add-relation keystone-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation keystone-mysql-router:shared-db keystone:shared-db

juju deploy /home/hdys/openstack/charms/charm-hacluster keystone-hacluster --config cluster_count=3
juju add-relation keystone-hacluster:ha keystone:ha

juju add-relation keystone:identity-service neutron-api:identity-service
juju add-relation keystone:certificates vault:certificates

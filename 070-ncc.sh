juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 070-ncc.yaml nova-cloud-controller

juju deploy --channel 8.0/stable mysql-router ncc-mysql-router
juju add-relation ncc-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation ncc-mysql-router:shared-db nova-cloud-controller:shared-db

juju deploy /home/hdys/openstack/charms/charm-hacluster ncc-hacluster --config cluster_count=3
juju add-relation ncc-hacluster:ha nova-cloud-controller:ha

juju add-relation nova-cloud-controller:identity-service keystone:identity-service
juju add-relation nova-cloud-controller:amqp rabbitmq-server:amqp
juju add-relation nova-cloud-controller:neutron-api neutron-api:neutron-api
juju add-relation nova-cloud-controller:cloud-compute nova-compute:cloud-compute
juju add-relation nova-cloud-controller:certificates vault:certificates

juju deploy --to lxd:0 --series bionic memcached
# juju config memcached repcached=true
juju add-relation memcached:cache nova-cloud-controller:memcache

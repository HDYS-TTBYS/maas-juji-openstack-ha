juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 100-glance.yaml glance

juju deploy --channel 8.0/stable mysql-router glance-mysql-router
juju add-relation glance-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation glance-mysql-router:shared-db glance:shared-db

juju deploy /home/hdys/openstack/charms/charm-hacluster glance-hacluster --config cluster_count=3
juju add-relation glance-hacluster:ha glance:ha

juju add-relation glance:image-service nova-cloud-controller:image-service
juju add-relation glance:image-service nova-compute:image-service
juju add-relation glance:identity-service keystone:identity-service
juju add-relation glance:certificates vault:certificates

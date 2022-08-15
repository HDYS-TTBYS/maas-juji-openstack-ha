juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 090-dashboard.yaml openstack-dashboard

juju deploy --channel 8.0/stable mysql-router dashboard-mysql-router
juju add-relation dashboard-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation dashboard-mysql-router:shared-db openstack-dashboard:shared-db

juju deploy /home/hdys/openstack/charms/charm-hacluster dashboard-hacluster --config cluster_count=3
juju add-relation dashboard-hacluster:ha openstack-dashboard:ha

juju add-relation openstack-dashboard:identity-service keystone:identity-service
juju add-relation openstack-dashboard:certificates vault:certificates

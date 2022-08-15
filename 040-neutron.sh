juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel 22.03/stable --config 040-neutron.yaml ovn-central

juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 040-neutron.yaml neutron-api

juju deploy --channel yoga/stable neutron-api-plugin-ovn
juju deploy --channel 22.03/stable --config 040-neutron.yaml ovn-chassis

juju deploy /home/hdys/openstack/charms/charm-hacluster neutron-api-hacluster --config cluster_count=3
juju add-relation neutron-api-hacluster:ha neutron-api:ha

juju add-relation neutron-api-plugin-ovn:neutron-plugin neutron-api:neutron-plugin-api-subordinate
juju add-relation neutron-api-plugin-ovn:ovsdb-cms ovn-central:ovsdb-cms
juju add-relation neutron-api-plugin-ovn:certificates vault:certificates

juju add-relation ovn-central:certificates vault:certificates
juju add-relation ovn-chassis:certificates vault:certificates

juju add-relation ovn-chassis:ovsdb ovn-central:ovsdb
juju add-relation ovn-chassis:nova-compute nova-compute:neutron-plugin
juju add-relation neutron-api:certificates vault:certificates

juju deploy --channel 8.0/stable mysql-router neutron-api-mysql-router
juju add-relation neutron-api-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation neutron-api-mysql-router:shared-db neutron-api:shared-db

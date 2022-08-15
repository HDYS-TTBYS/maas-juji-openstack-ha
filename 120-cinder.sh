juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel yoga/stable --config 120-cinder.yaml cinder

juju deploy --channel 8.0/stable mysql-router cinder-mysql-router
juju add-relation cinder-mysql-router:db-router mysql-innodb-cluster:db-router
juju add-relation cinder-mysql-router:shared-db cinder:shared-db

juju deploy /home/hdys/openstack/charms/charm-hacluster cinder-hacluster --config cluster_count=3
juju add-relation cinder-hacluster:ha cinder:ha

juju add-relation cinder:cinder-volume-service nova-cloud-controller:cinder-volume-service
juju add-relation cinder:identity-service keystone:identity-service
juju add-relation cinder:amqp rabbitmq-server:amqp
juju add-relation cinder:image-service glance:image-service
juju add-relation cinder:certificates vault:certificates

juju deploy --channel yoga/stable cinder-ceph

juju add-relation cinder-ceph:storage-backend cinder:storage-backend
juju add-relation cinder-ceph:ceph ceph-mon:client
juju add-relation cinder-ceph:ceph-access nova-compute:ceph-access

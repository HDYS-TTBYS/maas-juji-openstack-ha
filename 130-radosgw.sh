juju deploy  -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel quincy/stable --config 130-radosgw.yaml ceph-radosgw

juju deploy /home/hdys/openstack/charms/charm-hacluster radosgw-hacluster --config cluster_count=3
juju add-relation radosgw-hacluster:ha ceph-radosgw:ha

juju add-relation ceph-radosgw:mon ceph-mon:radosgw

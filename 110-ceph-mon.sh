juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel quincy/stable --config 110-ceph-mon.yaml ceph-mon

juju add-relation ceph-mon:osd ceph-osd:mon
juju add-relation ceph-mon:client nova-compute:ceph
juju add-relation ceph-mon:client glance:ceph

juju deploy -n 3 --to lxd:0,lxd:1,lxd:2 --series jammy --channel 3.9/stable --config min-cluster-size=3 rabbitmq-server

juju add-relation rabbitmq-server:amqp neutron-api:amqp
juju add-relation rabbitmq-server:amqp nova-compute:amqp

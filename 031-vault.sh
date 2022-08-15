export VAULT_ADDR="http://192.168.1.??:8200"
vault operator init -key-shares=5 -key-threshold=3
export VAULT_TOKEN=

export VAULT_ADDR="http://192.168.1.??:8200"
vault operator unseal KEY-1
vault operator unseal KEY-2
vault operator unseal KEY-3

export VAULT_ADDR="http://192.168.1.??:8200"
vault operator unseal KEY-1
vault operator unseal KEY-2
vault operator unseal KEY-3

export VAULT_ADDR="http://192.168.1.??:8200"
vault operator unseal KEY-1
vault operator unseal KEY-2
vault operator unseal KEY-3

vault token create -ttl=10m
juju run-action --wait vault/leader authorize-charm token=

juju run-action --wait vault/leader generate-root-ca

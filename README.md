# MAASとJujuでOpenstackをHA構成でデプロイする
<br>

## 構成
|  アプリケーション  |  数  |  説明  |
| ---- | ---- | ---- |
|  ceph  |  3  |  分散ストレージ  |
|  mysql  |  3  |  データベース  |
|  vault  |  3  |  機密情報ストレージ  |
|  neutron  |  3  |  ネットワーク機能 ルーティング、ファイアウォール、ロードバランシング、VPN など  |
|  keystone  |  3  |  ユーザーの認証/認可を管理する  |
|  rabbitmq  |  3  |  メッセージ・キューイング  |
|  nove  |  3  |  コンピュートリソースを提供する |
|  placement  |  3  |  仮想サーバ等の配置 |
|  horizon  |  3  |  ダッシュボード |
|  glance  |  3  |  マシンイメージを管理する |
|  cinder  |  3  |  Nova で払い出したコンピュートリソースにボリュームを提供する |

下記URLの内容を参考にしました。

https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/

## ハードウェア要件
---
(成功した条件)
- MAAS 3.1.0
- Juju 2.9.33
- OpenStack Yoga
---
- 1 x MAAS システム: 8GiB RAM、2 CPU、1 NIC、1 x 40GiB ストレージ
  - 実機で用意
  - Ubuntu 20.04 LTS (Focal)
- 1 x Juju コントローラーノード: 4GiB RAM、4 CPU、1 NIC、1 x 40GiB ストレージ
  - proxmox仮想マシン
  - Ubuntu 20.04 LTS (Focal)
- 3 x クラウド ノード: 18GiB RAM、6 CPU、1 NIC、1 x 80GiB ストレージ 1 x 32GiB ストレージ
  - proxmox仮想マシン
  - Ubuntu 22.04 LTS (Jammy )
  - プロセッサをhostにする

## MAASサーバーを用意する
---
サーバーにUbuntu 20.04 LTS (Focal)をインストールする
- ip 192.168.1.2

## MAAS のインストール
---
- サブネット 192.168.1.0/24
- MAAS ip 192.168.1.2

```
sudo snap install maas-test-db
sudo snap install maas --channel=3.1/stable
sudo maas init region+rack --maas-url http://192.168.1.2:5240/MAAS --database-uri maas-test-db:///
sudo maas createadmin --username admin --password ubuntu --email admin@example.com
sudo maas apikey --username admin > ~/admin-api-key
```

## Web UIにアクセスする
---
http://192.168.1.2:5240/MAAS

ユーザー名:admin

パスワード：ubuntu

22.04 LTS AMD64 イメージが必要


## DHCPを有効にする
---
https://maas.io/docs/how-to-manage-ip-addresses

MAASのDHCPを有効にする

(例)
|  START IP ADDRESS  |  END IP ADDRESS  |
| ---- | ---- |
|  192.168.1.150  |  192.168.1.199  |

既存のDHCPを無効にする

## DNSを設定する
---
(例)

Name: lab.hdys.home

## IP範囲を予約する
---
(例)
|  START IP ADDRESS  |  END IP ADDRESS  |  COMMENT  |
| ---- | ---- | ---- |
|  192.168.1.150  |  192.168.1.199  |  DHCP  |
|  192.168.1.200  |  192.168.1.219  |  openstack VIP  |
|  192.168.1.220  |  192.168.1.249  |  openstack floating IP  |
|  192.168.1.250  |  192.168.1.254  |  etc  |



## ノードを追加する
---
「ネットブート」 (PXE ブート) して MAAS クラスターに追加


## ノードの電源タイプの構成
---
https://maas.io/docs/power-management-reference


## Commission ノード
---
4つのノードを選択し、緑色の[Take action] ボタンを使用して [Commission] を選択し、これらのノードをコミッションします。正常に委託されたノードは、「準備完了」のステータスを取得します。これには数分かかります。

## ノードの名前変更
---
Jujuコントローラーノードに「controller」、3 つのクラウドノードに「node1」から「node3」

## タグの追加
---
Jujuコントローラーノードに「juju」、3 つのクラウドノードに「compute」

## OVS ブリッジの作成
---
3つのcomputeノードに設定する。
|  Bridge name  |  Fabric  |  Bridge type  |  VLAN  |  MAC address  |  Subnet  |  Tags  |  IP mode  |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
|  br-ex  |  fabric-0  |  Open vSwitch(ovs)  |  untagged  |    |  192.168.1.0/24  |    |  Auto assign  |


## Jujuをインストールする
---
```
sudo snap install juju --classic
```

## MAAS を Juju に追加する
---
maas-cloud.yaml
```yaml
clouds:
  maas-one:
    type: maas
    auth-types: [oauth1]
    endpoint: http://192.168.1.2:5240/MAAS
```
```
juju add-cloud --client -f maas-cloud.yaml maas-one
```

## MAAS クレデンシャルを追加する
---
maas-creds.yaml
```yaml
credentials:
  maas-one:
    anyuser:
      auth-type: oauth1
      maas-oauth: {~/admin-api-key}
```
```
juju add-credential --client -f maas-creds.yaml maas-one
```

## Juju コントローラの作成
---
```
juju bootstrap --bootstrap-series=focal --constraints tags=juju maas-one maas-controller
```

## モデルを作成する
---
```
juju add-model --config default-series=jammy openstack
```

## OpenStack のデプロイ
---
```
. deploy.sh
```

## 監視
---
```
. juju-watch-status
```

## 待つ
---
安定するまで待つ

## vaultを設定
---
https://charmhub.io/vault

031-vault.sh 参照

## デプロイが失敗したら
---
```
juju remove-application ***
```
000-ceph0osd.sh ~ 130-radosgw.shを参照して
```
juju deploy ***
juju add-relation *** ***
```

## MAASにDNSを設定する
---
(例)
|  NAME  |  DATA  |
| ---- | ---- |
|  cinder  |  192.168.1.201  |
|  compute  |  192.168.1.205  |
|  glance  |  192.168.1.202  |
|  keystone  |  192.168.1.203  |
|  neutron-api  |  192.168.1.204  |
|  openstack  |  192.168.1.206  |
|  placement  |  192.168.1.207  |
|  storage  |  192.168.1.200  |

## ダッシュボードへのアクセス
---
パスワードは Keystone から照会できます。
```
juju run --unit keystone/leader leader-get admin_passwd
```

ダッシュボードの URL は次のようになります。

https://openstack.lab.hdys.home/horizon

ログインに必要な最終的な認証情報は次のとおりです。

- ユーザー名:admin
- パスワード: ****************
- ドメイン: admin_domain

## OpenStack クライアントをインストールする
---
```
sudo snap install openstackclients
```

## 管理ユーザー環境の作成
---
```
git clone https://github.com/openstack-charmers/openstack-bundles ~/openstack-bundles
source ~/openstack-bundles/stable/openstack-base/openrc

env | grep OS_
```

## イメージとフレーバーの作成
---
```
mkdir ~/cloud-images

curl http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
   --output ~/cloud-images/jammy-amd64.img
   
openstack image create --public --container-format bare \
   --disk-format qcow2 --file ~/cloud-images/jammy-amd64.img \
   jammy-amd64

openstack flavor create --ram 2048 --disk 20 --ephemeral 20 m1.small
```

## パブリック ネットワークの設定
---
```
openstack network create --external --share \
   --provider-network-type flat --provider-physical-network physnet1 \
   ext_net

openstack subnet create --network ext_net --no-dhcp \
   --gateway 192.168.1.1 --subnet-range 192.168.1.0/24 \
   --allocation-pool start=192.168.1.220,end=192.168.1.249 \
   ext_subnet
```

## 管理者以外のユーザー環境を作成する
---
```
openstack domain create domain1
openstack project create --domain domain1 project1
openstack user create --domain domain1 --project project1 --password-prompt user1

User Password:ubuntu
Repeat User Password:ubuntu
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| default_project_id  | 47c42bfc695c4efcba92ab2345336265 |
| domain_id           | 884c9966c24f4db291e2b89b27ce692b |
| enabled             | True                             |
| id                  | 867f04fa967148b88953f810de72b530 |
| name                | User1                            |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

openstack role add --user 867f04fa967148b88953f810de72b530 \
   --project project1 Member

echo $OS_AUTH_URL
```

```
vim project1-rc
```

```
export OS_AUTH_URL=https://192.168.1.***:5000/v3
export OS_USER_DOMAIN_NAME=domain1
export OS_USERNAME=user1
export OS_PROJECT_DOMAIN_NAME=domain1
export OS_PROJECT_NAME=project1
export OS_PASSWORD=ubuntu
```
```
source project1-rc
echo $OS_USERNAME
```

## プライベート ネットワークのセットアップ
---
```
openstack network create --internal user1_net

openstack subnet create --network user1_net --dns-nameserver 192.168.1.2 \
   --subnet-range 192.168.0/24 \
   --allocation-pool start=192.168.0.10,end=192.168.0.199 \
   user1_subnet

openstack router create user1_router
openstack router add subnet user1_router user1_subnet
openstack router set user1_router --external-gateway ext_net
```

## SSH とセキュリティ グループの構成
---
```
mkdir ~/cloud-keys

ssh-keygen -q -N '' -f ~/cloud-keys/user1-key

openstack keypair create --public-key ~/cloud-keys/user1-key.pub user1

openstack security group create --description 'Allow SSH' Allow_SSH
openstack security group rule create --proto tcp --dst-port 22 Allow_SSH
```

## インスタンスの作成とアクセス
---
```
openstack server create --image jammy-amd64 --flavor m1.small \
   --key-name user1 --network user1_net --security-group Allow_SSH \
   jammy-1

FLOATING_IP=$(openstack floating ip create -f value -c floating_ip_address ext_net)
openstack server add floating ip jammy-1 $FLOATING_IP

openstack server list
```
次の方法でインスタンスに接続します。
```
ssh -i ~/cloud-keys/user1-key ubuntu@$FLOATING_IP
```

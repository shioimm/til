## 配線
1. L2スイッチとL3スイッチを配線 (V1)
2. L3スイッチとFWを配線 (V2-FW1)
3. FWとWAN-GWを配線 (FW2-)

## 設定
ホストマシンをL3スイッチのコンソールポートに接続

```
Switch>enable
Switch#configure terminal

Switch(config)#line console 0
Switch(config-line)#exit
Switch(config)#interface fastEthernet 0/5

Switch#show running-config
Switch#show interfaces
Switch#show version
Switch#show log

Switch>enable
Switch#configure terminal

Switch(config)#hostname L01
L01(config)#enable password ****
L01(config)#line vty 0 4
L01(config-line)#password ****
L01(config-line)#login
L01(config-line)#exit

L01(config)#no cdp run

L01(config)#interface fastEthernet 1/0/1
L01(config-if)#switchport mode access
L01(config-if)#exit

L01(config)#interface fastEthernet 1/0/2
L01(config-if)#switchport access vlan 2
L01(config-if)#exit

L01(config)#ip routing
L01(config)#interface vlan1

# VLAN1にIPアドレスを割り当てる
# L01(config-if)#ip address VLANに割り当てるIPアドレス) (このアドレスが属するネットワークの範囲)
L01(config-if)#ip address <A.A.A.A> 255.255.255.0
L01(config-if)#no shutdown
L01(config-if)#exit

# デフォルトルートの設定
L01(config)#ip route 0.0.0.0 0.0.0.0 <A.A.A.A>

L01(config)#ip dhcp pool vlan1-pool
# DHCPサーバがどのネットワークにIPを配るかを指定
L01(dhcp-config)#network <B.B.B.B> 255.255.255.0
# デフォルトゲートウェイのIPアドレスを指定
L01(dhcp-config)#default-router <A.A.A.A>
L01(dhcp-config)#dns-server 8.8.8.8
L01(dhcp-config)#exit

# DHCP割当対象から除外する
L01(config)#ip dhcp excluded-address **.*.*.*** **.*.*.***
L01(config)#exit

L01#copy running-config startup-config
```

その他FW側の設定 (GUI)

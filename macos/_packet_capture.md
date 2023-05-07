# パケットキャプチャ

```
# ネットワークインターフェース名を取得
$ networksetup -listallhardwareports

# tcpdump(1)を実行
$ sudo tcpdump -i ネットワークインターフェース -s 0 -B 524288 -w ~/Desktop/DumpFile01.pcap
$ tcpdump -s 0 -n -e -x -vvv -r ~/Desktop/DumpFile01.pcap
```

## 参照
- [Recording a Packet Trace](https://developer.apple.com/documentation/network/recording_a_packet_trace#//apple_ref/doc/uid/DTS10001707-CH1-SECNOTES)

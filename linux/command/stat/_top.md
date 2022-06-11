# top(1)
- プロセスの起動状況をリアルタイムに表示する

```
$ top

Processes:  488 total, 2 running, 486 sleeping, 2778 threads
Load Avg:   1.97, 2.65, 2.87  CPU usage: 2.67% user, 4.45% sys, 92.86% idle
SharedLibs: 221M resident, 26M data, 16M linkedit.
MemRegions: 912460 total, 2292M resident, 84M private, 1013M shared.
PhysMem:    8005M used (2866M wired), 185M unused.
VM:         58T vsize, 2320M framework vsize, 5285261978(380) swapins, 5333956933(0) swapouts.

Networks: packets: 121606220/110G in, 104230337/47G out. Disks: 622961147/24T read, 194447783/22T written.

PID    COMMAND      %CPU TIME     #TH   #WQ  #PORT MEM    PURG   CMPRS  PGRP  PPID  STATE    BOOSTS
81622  top          12.6 00:18.94 1/1   0    32    6420K  0B     0B     81622 76508 running  *0[1]
```

# 独習アセンブラ
    .global rdtsc
    .text
rdtsc:
    rdtscp
    ret

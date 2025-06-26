#!/bin/bash

# Enable a normally distributed delay of .15ms with 0.5ms jitter
# The idea is to better simulate a cloud environment
tc qdisc add dev eth0 root netem delay 150us 200us distribution normal

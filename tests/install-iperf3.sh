#!/bin/bash

for i in $(seq 1 7); do
    echo "Installing iPerf3 on ue$i..."
    docker exec --user root ue$i bash -c "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y iperf3"
done

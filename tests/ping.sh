#!/bin/bash

for j in $(seq 1 10); do   # 10 itérations
    for i in $(seq 1 7); do   # 7 UEs
        echo "[$j] Pinging google.com from UE $i ..."
        docker exec ue$i ping -c 4 google.com &
        sleep 1
    done
done

wait
echo "Done."

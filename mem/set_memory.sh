#!/bin/bash
if [ -f $2 ]; then
    rm -f $1
    cp $2 $1
    echo "Detected size: $(cat $1 | wc -l)"
    for i in $(seq $(cat $1 | wc -w) 4096); do echo "00000000" >> $1 ; done
fi


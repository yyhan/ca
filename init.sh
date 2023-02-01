#!/bin/bash


mkdir -p data
mkdir -p ca_root
mkdir -p certs
mkdir -p newcerts

touch ./data/index.txt

if [ ! -f "./data/serial" ]
then
    echo "01" > ./data/serial
fi

if [ ! -f "./data/crl_number" ]
then
    echo "01" > ./data/crl_number
fi

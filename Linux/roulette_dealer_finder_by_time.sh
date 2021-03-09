#!/bin/bash

 echo "$1"

grep -iF "$2" "$1"_Dealer_schedule | awk -F" " '{print $1,$2,$5,$6}'

#!/bin/bash

grep -iF "$2" "$1"_Dealer_schedule | awk -F" " '{print $5,$6}'


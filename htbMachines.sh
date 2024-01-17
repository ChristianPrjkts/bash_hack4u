#!/bin/bash

function ctrl_c()
{
  echo -e "\n[+] Aborting operation...\n"

  tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT


#!/bin/bash

#Colours from https://github.com/s4vitar/evilTrust/blob/master/evilTrust.sh
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c()
{
  echo -e "\t${redColour}[+] Aborting operation...${endColour}\n"

  tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT

# global variables
main_url="https://htbmachines.github.io/bundle.js"

# helpPanel
function helpPanel ()
{
  echo -e "\t${purpleColour}[>] m)${endColour} ${grayColour}Search Machine in data base: -m \"[machine-name]\"${endColour}"
  echo -e "\t${purpleColour}[>] u)${endColour} ${grayColour}Download or update source for search engine.${endColour}"
  echo -e "\t${purpleColour}[>] i)${endColour} ${grayColour}Search IP address in data base: -i \"[ip-address]\"${endColour}"
  echo -e "\t${purpleColour}[>] y)${endColour} ${grayColour}Getting machine solution link: -y \"[machine-name]\"${endColour}"
  echo -e "\t${purpleColour}[>] d)${endColour} ${grayColour}List machines by difficulty: -d "[machine-difficulty]"${endColour}"
  echo -e "\t${purpleColour}[>] h)${endColour} ${grayColour}Show help panel.${endColour}"
}

# updateing files or download sources
function updateFiles ()
{
  tput civis # hide cursor

  if [ ! -f bundle.js ]; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Downloading source for search engine...${endColour}\n"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}All sources downloaded${endColour}" 
  else
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Checking for updates...${endColour}\n"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}') # hash bundle_temp.js
    md5_original_value=$(md5sum bundle.js | awk '{print $1}') # hash bundle.js

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${redColour}[!]${endColour} ${grayColour}No updates found!${endColour}\n"
      rm -r bundle_temp.js
    else
      echo -e "\n${greenColour}[+]${endColour} ${grayColour}Updates found... Sources updated${endColour}\n"
      rm bundle.js && mv bundle_temp.js bundle.js
    fi
  fi

  tput cnorm # cursor normal mode 
}

# Check if the argument exist un the source file
function checkPattern ()
{
  pattern="$1"
  # taking pattern from string, silent mode -q, case sensitive -i
  grep -qi "$pattern" bundle.js
  # status (0 suceed/1 error)
  return $?
}

# Searchinf machine with name
function searchMachine ()
{
  machineName="$1"
  
  if checkPattern "$machineName"; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}Showing features of: $machineName${endColour}\n"
    #awk "tolower(\$0) ~ tolower(\"name: \\\"$machineName\\\"\"),/resuelta:/" bundle.js | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    awk "tolower(\$0) ~ tolower(\"name: \\\"$machineName\\\"\"),/resuelta:/" bundle.js | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk -v blue="\033[0;34m\033[1m" -v gray="\033[0;37m\033[1m" '{print blue $1 gray $2 "\033[0m\033[0m"}'
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}Machine not found!${endColour}\n"
  fi

}

function searchIP ()
{
  ipAddress="$1"

  if checkPattern $ipAddress; then
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}The IP address: $ipAddress coresponds to machine: ${endColour}\n"
    echo -e "${blueColour}$(grep "ip: \"$ipAddress\"" -B 3 bundle.js | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')${endColour}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}IP address not found!${endColour}\n"
  fi
}

function getYoutubeLink ()
{
  machineName="$1"
  if checkPattern $machineName; then
    youtubeLink=$(awk "tolower(\$0) ~ tolower(\"name: \\\"$machineName\\\"\"),/resuelta:/" bundle.js | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube: " | awk 'NF{print $NF}')
    echo -e "\n${greenColour}[+]${endColour} ${grayColour}The solution for the machine $machineName is in:${endColour} ${blueColour}$youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!]${endColour} ${grayColour}Machine not found!${endColour}\n"
  fi
}

function getMachineDiffculty ()
{
   machineDifficulty="$1"

   if checkPattern $machineDifficulty; then
    echo -e "\n[+] List of machines with difficulty: $machineDifficulty\n"
    echo -e "\n${blueColour}$(grep -i "\"$machineDifficulty\"" bundle.js -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)${endColour}\n"
    #grep -i "dificultad: \"$machineDifficulty\"" bundle.js -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
   else
    echo -e "\n[!] Difficulty not found in machines!\n"
   fi
}

# indicators
declare -i parameter_counter=0

# menu setting variables state
while getopts "m:i:y:d:hu" param; do
  case $param in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let parameter_counter+=5;;
    h) ;;
  esac
done

# setting variables
if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachineDiffculty $difficulty
else
  helpPanel
fi

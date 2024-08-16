#!/bin/zsh

function install_egil {
  echo "Add egil.sh to system?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo -e "alias egil='~/gam/./.egil.sh'" >> ~/.zshrc; break;;
          No ) break;;
      esac
  done
}

function download_egil {
  echo "Do you wish to download the latest egil-kommandon file?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) curl https://raw.githubusercontent.com/mattiasbystedt/egil-kommandon/master/egil.sh > ~/gam/.egil.sh; break;;
          No ) exit;;
      esac
  done
}

# message during install
usage()
{
cat << EOF
----
EGIL-KOMMANDON installation script running...
----

EOF
}

usage

if grep -Fxq 'alias egil'  ~/.zshrc
then
    echo "EGIL-KOMMANDON found"
else
    echo "EGIL-KOMMANDON not found"
    install_egil
fi

download_egil

echo "Done! Now type 'exit' and restart terminal"

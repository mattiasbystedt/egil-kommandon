#!/bin/zsh

function install_egil {
  echo "Add egilkommandon.sh to system?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) echo -e "alias egil='~/gam/./.egil.sh'" >> ~/.zshrc; break;;
          No ) exit;;
      esac
  done
}

function download_egil {
  echo "Do you wish to download the latest egil-kommando file?"
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

case `grep 'alias egil='~/gam/./.egilkommandon.sh'' ~/.zshrc >/dev/null; echo $?` in
  0)
    echo "EGIL-KOMMANDON found"
    download_egil
    ;;
  1)
    echo "EGIL-KOMMANDON not found"
    install_egil
    download_egil
    ;;
  *)
    echo "error finding .kommandon"
    ;;
esac

echo "Done! Now type 'exit' and restart terminal"

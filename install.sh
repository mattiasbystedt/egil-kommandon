#!/bin/zsh

# TODO - adapt setup script to EGIL-KOMMANDON

checkos=$(uname -s)
echo $checkos

# install or update new commands
add_kommandon()
{
  # check for dir "gam"
  if [ -d ~/gam ]; then
    echo "dir 'gam' found"
  else
    mkdir ~/gam
  fi
  curl https://raw.githubusercontent.com/mattiasbystedt/egil-kommandon/master/egil.sh > ~/gam/.egilkommandon.sh
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

# setup AD user and password

# check install or update
zsh_string="if [ -f ~/gam/.egilkommandon ]; then\n    . ~/.kommandon\n    source ~/.kommandon\nfi"
profile_string="source ~/.zshrc"
case `grep "kommandon" ~/.bashrc >/dev/null; echo $?` in
  0)
    echo "EGIL-KOMMANDON found - updating with new commands"
    add_kommandon
    ;;
  1)
    echo "KOMMANDON not found - first install"
    echo -e ${bash_string} >> ~/.bashrc
    if [ "$checkos" = ""Darwin"" ]; then
      touch ~/.bash_profile
      echo -e ${profile_string} >> ~/.bash_profile
    fi
    add_kommandon
    ;;
  *)
    echo "error finding .kommandon"
    ;;
esac

echo "Now type 'exit' and restart terminal"

#!/bin/sh

check_zsh_installed() {
  ZSH_VERSION=`zsh --version 2> /dev/null`

  if [ $? -eq 0 ]; then
    printf "\e[1;32mFound zsh installation: \e[0m$ZSH_VERSION\n"
  else
    printf "\e[0;31mNo installation of zsh was found. Please, install zsh before running this script\e[0m\n"
    exit 1
  fi
}

check_homebrew_installed() {
  BREW_VERSION=`brew --version | head -n 1`

  if [ $? -eq 0 ]; then
    printf "\e[1;32mFound Homebrew installation: \e[0m$BREW_VERSION\n"
  else
    printf "\e[0;31mNo installation of Homebrew was found. Please, head to https://brew.sh/ and install Homebrew before running this script\e[0m\n"
    exit 1
  fi
}

install_zplug_if_required() {
  brew list zplug > /dev/null 2> /dev/null

  if [ $? -eq 0 ]; then
    printf "\e[1;32mFound zplug installation\e[0m\n"
  else
    printf "\e[1;33mNo installation of zplug was found. Installing it...\e[0m\n"
    brew install zplug > /dev/null

    if [ $? -eq 0 ]; then
      printf "\e[1;32mzplug installed successfully\e[0m\n"
    else
      printf "\e[0;31mzplug installation failed. Please, head to https://github.com/zplug/zplug and install it manually before running this script\e[0m\n"
      exit 1
    fi
  fi
}

check_zsh_installed
check_homebrew_installed
install_zplug_if_required

rm -rf ~/.zshrc-sources
mkdir ~/.zshrc-sources

echo "# ============ AUTOMATED DEPLOYMENT ============ #" >> ~/.zshrc

cp zshrc_zplug ~/.zshrc-sources/
echo "source ~/.zshrc-sources/zshrc_zplug" >> ~/.zshrc

cp zshrc_system ~/.zshrc-sources/
echo "source ~/.zshrc-sources/zshrc_system" >> ~/.zshrc

cp zshrc_aliases ~/.zshrc-sources/
echo "source ~/.zshrc-sources/zshrc_aliases" >> ~/.zshrc

echo "# ============ END OF AUTOMATED DEPLOYMENT ===== #" >> ~/.zshrc

printf "\n\e[1;32mDEPLOYMENT COMPLETED SUCCESSFULLY \e[0m\n"


#!/bin/bash

install_paru() {
  if ! command -v paru &>/dev/null; then
    log INFO "Installing paru..."
    sudo pacman -Syu --needed --noconfirm base-devel git || { log ERROR "Failed deps"; exit 1; }
    paru_dir=$(sudo -u "$USER_NAME" mktemp -d /tmp/paru.XXXXXX) || { log ERROR "Temp dir failed"; exit 1; }
    trap "rm -rf '$paru_dir'" EXIT
    sudo -u "$USER_NAME" git clone https://aur.archlinux.org/paru.git "$paru_dir" || { log ERROR "Clone failed"; exit 1; }
    pushd "$paru_dir" >/dev/null
    sudo -u "$USER_NAME" HOME="$USER_HOME" makepkg -si --noconfirm || { log ERROR "Makepkg failed"; exit 1; }
    popd >/dev/null
    if ! command -v paru &>/dev/null; then log ERROR "Verification failed"; exit 1; fi
    log SUCCESS "Paru installed!"
  else
    log INFO "Paru already installed."
  fi
}

update_system() {
  log INFO "Updating system..."
  sudo pacman -Syu --noconfirm || { log ERROR "Update failed"; exit 1; }
  log SUCCESS "System updated!"
}

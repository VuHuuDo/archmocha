#!/bin/bash

install_paru() {
  # Check if paru is not installed
  if ! command -v paru &>/dev/null; then
    # Log start of paru installation
    log INFO "Installing paru (AUR helper)..."

    # Install base-devel and git if needed
    sudo pacman -Sy --needed --noconfirm base-devel git &
    local pid=$!
    spinner $pid "Installing base-devel and git..."
    wait $pid || { log ERROR "Failed to install base-devel and git!"; exit 1; }

    # Prepare temporary directory for paru using mktemp for safety
    local paru_dir
    paru_dir=$(mktemp -d /tmp/paru.XXXXXX) || { log ERROR "Failed to create temporary directory!"; exit 1; }
    trap "rm -rf '$paru_dir'" EXIT  # Ensure cleanup on exit

    # Clone paru repo from AUR as the user
    sudo -u "$USER_NAME" git clone https://aur.archlinux.org/paru.git "$paru_dir" &
    local pid=$!
    spinner $pid "Cloning paru repository..."
    wait $pid || { log ERROR "Failed to clone paru repository!"; exit 1; }

    # Build and install paru using makepkg as the user
    pushd "$paru_dir" >/dev/null || { log ERROR "Failed to change directory to $paru_dir!"; exit 1; }
    sudo -u "$USER_NAME" HOME="$USER_HOME" makepkg -si --noconfirm &
    local pid=$!
    spinner $pid "Building and installing paru..."
    wait $pid || { log ERROR "Failed to build and install paru!"; exit 1; }
    popd >/dev/null

    # Verify paru installation
    if ! command -v paru &>/dev/null; then
      log ERROR "Paru installation verification failed! Paru is not available after installation."
      exit 1
    fi

    # Log success
    log SUCCESS "Paru installed successfully!"
  else
    # Log if paru already exists
    log INFO "Paru is already installed, skipping installation."
  fi
}

update_system() {
  # Log start of system update
  log INFO "Updating system..."

  # Run pacman update non-interactively
  sudo pacman -Syu --noconfirm &
  local pid=$!
  spinner $pid "Updating system packages..."
  wait $pid || { log ERROR "System update with pacman failed!"; exit 1; }

  # Log success
  log SUCCESS "System updated successfully!"
}
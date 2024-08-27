# NixOS Setup Guide

This guide will help you set up the necessary NixOS channels, install Git, clone a configuration repository, and rebuild your NixOS system.

## Prerequisites

- A fresh NixOS installation.
- Basic knowledge of using the terminal.

## Steps to Install Channels

### 1. Update NixOS System

Ensure that your NixOS system is up-to-date:

```bash
sudo nixos-rebuild switch --upgrade
```

### 2. List Current Channels

To see which channels are currently configured:

```bash
nix-channel --list
```

### 3. Add the Channels

Add the following channels:

#### 3.1 Add `catppuccin` Channel

```bash
sudo nix-channel --add https://github.com/catppuccin/nix/archive/main.tar.gz catppuccin
```

#### 3.2 Add `home-manager` Channel

```bash
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
```

#### 3.3 Add `nixos` Channel

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-24.05 nixos
```

### 4. Update the Channels

Update the channels to fetch the latest package information:

```bash
sudo nix-channel --update
```

### 5. Verify the Channels

Confirm the channels have been added correctly:

```bash
nix-channel --list
```

You should see:

```
catppuccin https://github.com/catppuccin/nix/archive/main.tar.gz
home-manager https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz
nixos https://nixos.org/channels/nixos-24.05
```

### 6. Rebuild Your NixOS Configuration

Apply any changes and rebuild your NixOS configuration:

```bash
sudo nixos-rebuild switch
```

## Install Git and Clone Configuration Repository

### 1. Enter a `nix-shell` and Install Git

Use `nix-shell` to install Git temporarily:

```bash
nix-shell -p git
```

### 2. Clone the Configuration Repository

Clone the repository into your home directory:

```bash
git clone https://github.com/LastoftheDinosaurs/nixos-config.git ~/nixos-config
```

### 3. Move Configuration Files

Move the necessary configuration files into `/etc/nixos`:

```bash
sudo mv ~/nixos-config/configuration.nix /etc/nixos/
sudo mv ~/nixos-config/modules /etc/nixos/
sudo mv ~/nixos-config/themes /etc/nixos/
```

### 4. Rebuild NixOS Configuration

Rebuild your NixOS configuration to apply the new settings:

```bash
sudo nixos-rebuild switch
```

## Conclusion

You have now set up your NixOS system with the necessary channels, installed Git, cloned a configuration repository, and applied the new configuration. If you encounter any issues or need further assistance, refer to the [NixOS manual](https://nixos.org/manual/nixos/stable/) or seek help from the [NixOS community](https://discourse.nixos.org/).


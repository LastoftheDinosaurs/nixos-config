{ config, pkgs, ... }:

{
  # Import hardware configuration and modularized configurations
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>  # Include Home Manager module
    ./modules/home-manager.nix  # Modularized Home Manager configuration
  ];

  boot = {
    # Switch to latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader settings
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Plymouth configuration with adi1090x theme override
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # Hide the OS choice for bootloaders
    loader.timeout = 0;
  };

  # Networking settings
  networking = {
    hostName = "nixos";
    enableIPv6 = false;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
    };
  };

  # Timezone and Localization
  time.timeZone = "America/Chicago";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # X11 and Window Manager
  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      autoLogin.enable = true;
      autoLogin.user = "last";
    };
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
    displayManager.defaultSession = "none+awesome";
  };

  # Package settings
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    audit
    dive
    firefox
    git
    podman-compose
    podman-tui
    wget
    yubikey-manager
    yubikey-personalization
    ((vim_configurable.override { }).customize {
      name = "vim-with-plugins";

      # Install Vim plugins
      vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          vim-airline
          vim-nix
          vim-easy-align
          vim-go
          fzf
          vim-lastplace
        ];
        opt = [];
      };

      # Custom Vim configuration
      vimrcConfig.customRC = ''
        " Custom vimrc configuration
        set nocompatible
        set backspace=indent,eol,start
        syntax on
        set mouse=a
      '';
    })
  ];

  # Service settings
  services = {
    printing.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    cron.enable = true;
  };

  # Hardware settings
  hardware = {
    bluetooth.enable = false;
    pulseaudio.enable = false; # Prevent conflicts with PipeWire
  };

  # Security settings
  security = {
    rtkit.enable = true; # Real-time kernel support for PipeWire
    pam = {
      services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
      yubico = {
        enable = true;
        debug = true;
        mode = "challenge-response";
        id = [ "26900481" ];
      };
    };
    polkit.enable = true;
    audit.enable = true;
    auditd.enable = true;
    sudo = {
      enable = true;
      extraRules = [{
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl suspend";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.systemd}/bin/poweroff";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }];
      extraConfig = with pkgs; ''
        Defaults:picloud secure_path="${lib.makeBinPath [
          systemd
        ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
  };

  # Enable experimental features in Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User account configuration
  users.users.last = {
    isNormalUser = true;
    description = "Last";
    home = "/home/last";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [
      awesome
      steam
      libreoffice-fresh
      librewolf
      hunspell
      irssi
    ];
  };

  # Set environment variables
  environment.variables = {
    TERMINAL = "st";
    EDITOR = "vim";
    VISUAL = "vim";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
    XKB_DEFAULT_LAYOUT = "us";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
      ubuntu_font_family
      liberation_ttf
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Iosevka" ];
      };
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };
  };

  # Automatically clean the Nix Store
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  # Virtualization settings
  virtualisation = {
    containers.enable = true;

    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  # Add members to vboxusers group
  users.extraGroups.vboxusers.members = [ "last" ];

  # System-wide state version
  system.stateVersion = "24.05";  # This is the NixOS version
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };
}


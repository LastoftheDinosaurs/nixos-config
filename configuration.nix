{ config, pkgs, ... }:

{
  # Import hardware configuration and modularized configurations
  imports = [
    ./hardware-configuration.nix
    <catppuccin/modules/nixos>
    <home-manager/nixos>  # Include Home Manager module
    ./modules/home-manager.nix  # Modularized Home Manager configuration
  ];

  catppuccin.enable = true;
  catppuccin.flavor = "frappe";
  catppuccin.accent = "mauve";

  boot = {
    # Switch to latest kernel
    kernelPackages = pkgs.linuxPackages_6_6_hardened;

    # Bootloader settings
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Plymouth configuration with adi1090x theme override
    plymouth = {
      enable = true;
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
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager = {
      enable = true;
      dns = "none";
    };
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
    layout = "us";
    videoDrivers = [ "nvidia" ];
    dpi = 180;
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
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        accelProfile = "flat";
      };
    };
    displayManager.defaultSession = "none+awesome";
  };

  # Make Qt 5 applications look similar to GTK ones
  qt.enable = true;
  qt.platformTheme = "gtk2";
  qt.style = "gtk2";

  # Package settings
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

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
    vim
    ansible
    openvpn
    pwgen
    android-tools
    keepassxc
    aide
    xorg.xev
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
    openvpn.servers = {
      mullvadVPN  = { 
        config = '' config /etc/openvpn/mullvad_config_linux_us_all/mullvad_us_all.conf ''; 
        updateResolvConf = false;
      };
    };
    resolved.enable = false;
    cron.enable = true;
    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv4_servers = true;
        ipv6_servers = false;
        require_dnssec = true;
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        server_names = [ "adguard-dns" ];
      };
    };
  };

  # Hardware settings
  hardware = {
    bluetooth.enable = false;
    pulseaudio.enable = false; # Prevent conflicts with PipeWire
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        config.boot.kernelPackages.nvidiaPackages.production
      ];
    };
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
      (nerdfonts.override { fonts = [ "Iosevka" "JetBrainsMono" ]; })
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

  systemd.timers.aide-task = {
    enable = true;
    timerConfig = {
      OnCalendar = "daily";  # Adjust this to the desired frequency
      Unit = "aide-task.service";  # The service that the timer triggers
    };
    wantedBy = ["timers.target"];
  };

  systemd.services.aide-task = {
    enable = true;
    serviceConfig.Type = "oneshot";
    path = [ pkgs.aide ];  # Ensure 'pkgs.aide' is included in the path
    script = ''
      # Initialize AIDE database if it doesn't exist
      if [ ! -f /var/lib/aide/aide.db.gz ]; then
        echo "Initializing AIDE database..."
        aide --init
        cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
      else
        echo "Updating AIDE database..."
        aide --update
        cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
      fi

      # Perform a check against the AIDE database
      echo "Running AIDE check..."
      aide --check
    '';
  };

  # System-wide state version
  system.stateVersion = "24.05";  # This is the NixOS version
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };
}

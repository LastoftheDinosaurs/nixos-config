{ config, pkgs, ... }:

{
  # Import hardware configuration and Home Manager
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # Switch to latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader settings
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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
    wget
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
      git
      yubikey-personalization
      yubikey-manager
      audit
      awesome
      firefox
      steam
      libreoffice-fresh
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

  # GPG Agent with SSH support
  programs.gnupg.agent = {
    enable = true;
    #enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Automatically clean the Nix Store
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  # Enable VirtualBox with Extension Pack
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  # Add members to vboxusers group
  users.extraGroups.vboxusers.members = [ "last" ];

  # Home Manager configuration for user 'last'
  home-manager.users.last = { pkgs, ... }: {
    home.packages = with pkgs; [
      alacritty
      btop
      cava
      feh
      firefox
      fzf
      git
      gnupg
      irssi
      keychain
      mpv
      ncmpcpp
      vscodium
    ];

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" ];
        historyFile = "~/.bash_history";
        historySize = 250000;
        shellAliases.ll = "ls -l";
      };
      alacritty.enable = true;
      btop = {
        enable = true;
        settings = {
          color_theme = "Default";
          theme_background = false;
        };
      };
      cava = {
        enable = true;
        settings = {
          general.framerate = 60;
          input.method = "alsa";
          smoothing.noise_reduction = 88;
          color = {
            background = "'#000000'";
            foreground = "'#FFFFFF'";
          };
        };
      };
      dircolors = {
        enable = true;
        enableBashIntegration = true;
      };
      feh.enable = true;
      firefox.enable = true;
      fzf = {
        enable = true;
        enableBashIntegration = true;
      };
      git = {
        enable = true;
        userName = "LastoftheDinosaurs";
        userEmail = "last@dino.sh";
        signing.key = "4081F38C2F7100AF";
      };
      librewolf = {
        enable = true;
        settings = {
          "browser.cache.disk.enable" = false;  # Disable disk cache to prevent data persistence.
          "browser.cache.offline.enable" = false;  # Disable offline cache to prevent data retention.
          "browser.formfill.enable" = false;  # Disable form autofill to prevent leaking form data.
          "browser.sessionstore.privacy_level" = 2;  # Disable saving session data to prevent recovery after restart.
          "dom.security.https_only_mode" = true;  # Enable HTTPS-only mode.
          "extensions.webextensions.restrictedDomains" = "";  # Prevent web extensions from accessing sensitive domains.
          "geo.enabled" = false;  # Disable geolocation to prevent location tracking.
          "media.eme.enabled" = false;  # Disable DRM-controlled content.
          "media.peerconnection.enabled" = false;  # Disable WebRTC to prevent IP leaks.
          "network.cookie.cookieBehavior" = 1;  # Block all third-party cookies.
          "network.cookie.lifetimePolicy" = 2;  # Cookies expire at the end of the session.
          "network.dns.disablePrefetch" = true;  # Disable DNS prefetching to avoid potential tracking.
          "network.http.referer.XOriginPolicy" = 2;  # Only send the origin on cross-origin requests.
          "network.http.referer.XOriginTrimmingPolicy" = 2;  # Send only the origin in referrer headers across origins.
          "network.http.speculative-parallel-limit" = 0;  # Disable speculative parallel connections.
          "privacy.clearOnShutdown.cache" = true;  # Clear cache on shutdown.
          "privacy.clearOnShutdown.cookies" = true;  # Clear cookies on shutdown.
          "privacy.clearOnShutdown.downloads" = true;  # Clear download history on shutdown.
          "privacy.clearOnShutdown.history" = true;  # Clear browsing history on shutdown.
          "privacy.clearOnShutdown.offlineApps" = true;  # Clear offline apps data on shutdown.
          "privacy.clearOnShutdown.sessions" = true;  # Clear session data on shutdown.
          "privacy.donottrackheader.enabled" = true;  # Enable Do Not Track header.
          "privacy.donottrackheader.value" = 1;  # Set Do Not Track header to always.
          "privacy.firstparty.isolate" = true;  # Enable First-Party Isolation to mitigate cross-site tracking.
          "privacy.firstparty.isolate.block_post_message" = true;  # Block cross-origin communication via postMessage.
          "privacy.firstparty.isolate.restrict_opener_access" = true;  # Prevent cross-origin opener access.
          "privacy.partition.network_state" = true;  # Partition network state to prevent tracking.
          "privacy.reduceTimerPrecision" = true;  # Reduce the precision of timers to mitigate timing attacks.
          "privacy.resistFingerprinting" = true;  # Enable resistance to fingerprinting.
          "privacy.trackingprotection.enabled" = true;  # Enable tracking protection.
          "security.cert_pinning.enforcement_level" = 2;  # Enforce certificate pinning.
          "security.mixed_content.block_display_content" = true;  # Block insecure content on HTTPS pages.
          "security.mixed_content.send_hsts_priming" = false;  # Disable HSTS priming to reduce fingerprinting.
          "security.ssl.require_safe_negotiation" = true;  # Enforce secure SSL/TLS negotiation.
          "security.tls.version.min" = 3;  # Set minimum TLS version to TLS 1.2.
          "webgl.disabled" = true;  # Disable WebGL to reduce fingerprinting.
        };
      };
      vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          catppuccin.catppuccin-vsc
        ];
      };
    };

    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
    home.stateVersion = "24.05"; # This is the Home Manager version
  };

  # System-wide state version
  system.stateVersion = "24.05";  # This is the NixOS version
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };
}

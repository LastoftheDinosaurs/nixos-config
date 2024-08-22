{ config, pkgs, ... }:

{
  # Import hardware configuration
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Set your time zone
  time.timeZone = "America/Chicago";

  # Localization settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  # Enable X11 Windowing System
  services.xserver = {
    enable = true;

    # Configure display manager to use LightDM with auto-login for user 'last'
    displayManager = {
      lightdm.enable = true;
      lightdm.autoLogin.enable = true;
      lightdm.autoLogin.user = "last";
    };

    # Enable AwesomeWM
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks         # Lua package manager
        luadbi-mysql     # Database abstraction layer
      ];
    };

    # Optionally, set default session to AwesomeWM
    displayManager.defaultSession = "none+awesome";
  };

  nixpkgs.config.allowUnfree = true;

  # Disable printing service (CUPS)
  services.printing.enable = false;

  # Enable and configure PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable cron
  services.cron.enable = true;

  # Disable bluetooth
  hardware.bluetooth.enable = false;

  # Disable PulseAudio to avoid conflicts with PipeWire
  hardware.pulseaudio.enable = false;

  # Enable real-time kernel support for PipeWire
  security.rtkit.enable = true;

  # Security settings
  security.pam.services.login.u2fAuth = true;
  security.pam.services.sudo.u2fAuth = true;

  # Enable challenge-response authentication using YubiKey
  security.pam.yubico = {
    enable = true;
    debug = true;
    mode = "challenge-response";
    id = [ "26900481" ];
  };

  # Enable polkit, required for graphical interfaces
  security.polkit.enable = true;

  security.audit.enable = true;
  security.auditd.enable = true;

  # Enable experimental features in Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define user accounts
  users.users.last = {
    isNormalUser = true;
    description = "Last";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    home = "/home/last";
    packages = with pkgs; [
      git
      yubikey-personalization
      yubikey-manager
      audit
      awesome
      firefox
    ];
  };

  home-manager.backupFileExtension = "hm-backup";

  # Set environment variables
  environment.variables = {
    TERMINAL = "st";     # Set the terminal to st
    EDITOR = "vim";      # Set vim as the default editor
    VISUAL = "vim";      # Set vim as the visual editor
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";  # SSH agent socket
    XKB_DEFAULT_LAYOUT = "us";  # Set default keyboard layout
    NIXPKGS_ALLOW_UNFREE = "1"; # Allow unfree packages
    };

    # List additional packages to install in the system profile
    environment.systemPackages = with pkgs; [

    # wget
    (vim_configurable.customize {
      name = "vim-with-plugins";
      vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          vim-airline
          vim-nix
          #seoul256.vim            # Plugin 'junegunn/seoul256.vim'
          vim-easy-align          # Plugin 'https://github.com/junegunn/vim-easy-align.git'
          vim-go                  # Plugin 'fatih/vim-go', { 'tag': '*' }
          #coc.nvim                # Plugin 'neoclide/coc.nvim', { 'branch': 'release' }
          fzf                     # Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
        ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        " Custom vimrc configuration
        set nocompatible
        set backspace=indent,eol,start
        syntax on
        set mouse=a

        " Load plugins using Vim-Plug
        call plug#begin(stdpath('data') . '/plugged')

        Plug 'junegunn/seoul256.vim'
        Plug 'https://github.com/junegunn/vim-easy-align.git'
        Plug 'fatih/vim-go', { 'tag': '*' }
        Plug 'neoclide/coc.nvim', { 'branch': 'release' }
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

        call plug#end()
      '';
    })
  ];

  # Enables GnuPG agent with socket-activation for every user session.
  programs.gnupg.agent.enable = true;

  # Automatically clean the Nix Store
  nix.gc.automatic = true;
  nix.gc.dates = "03:15";

  home-manager.users.last = { pkgs, ... }: {
    home.packages = [ pkgs.alacritty pkgs.btop pkgs.cava pkgs.feh pkgs.firefox pkgs.fzf pkgs.git pkgs.gnupg pkgs.keychain pkgs.mpv pkgs.ncmpcpp pkgs.vscodium ];

    programs.bash.enable = true;
    programs.bash.enableCompletion = true;
    programs.bash.historyControl = [ "ignoredups" ];
    programs.bash.historyFile = "~/.bash_history";
    programs.bash.historySize = 250000;
    programs.bash.shellAliases = {
      ll = "ls -l";
    };

    programs.alacritty.enable = true;
    programs.btop.enable = true;
    programs.btop.settings = {
      color_theme = "Default";
      theme_background = false;
    };
    programs.cava.enable = true;
    programs.cava.settings = {
      general.framerate = 60;
      input.method = "alsa";
      smoothing.noise_reduction = 88;
      color = {
          background = "'#000000'";
          foreground = "'#FFFFFF'";
      };
  };

  programs.dircolors.enable = true;
  programs.dircolors.enableBashIntegration = true;

  programs.feh.enable = true;
  programs.firefox.enable = true;
  programs.fzf.enable = true;
  programs.fzf.enableBashIntegration = true;

  # GPG Agent with SSH support
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Git configuration specific to 'last'
  programs.git = {
    enable = true;
    userName = "LastoftheDinosaurs";
    userEmail = "last@dino.sh";
    signing.key = "4081F38C2F7100AF";
  };

  # Set SSH_AUTH_SOCK for GnuPG agent SSH support
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";

  programs.keychain.enable = true;
  programs.keychain.enableBashIntegration = true;

  programs.mpv.enable = true;
  programs.ncmpcpp.enable = true;

  # Removed vim from Home Manager configuration

  programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
          catppuccin.catppuccin-vsc
      ];
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
};

  system.stateVersion = "24.05"; # This is the NixOS version
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
}


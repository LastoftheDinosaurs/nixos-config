{ config, pkgs, catppuccin, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
    
    kernel.sysctl = {
        # Network Settings
        "net.ipv4.ip_forward" = 0; # Disable IP forwarding
        "net.ipv4.conf.all.rp_filter" = 1; # Enable reverse path filtering
        "net.ipv4.conf.default.rp_filter" = 1; # Enable reverse path filtering for default
        "net.ipv4.conf.all.accept_source_route" = 0; # Disable source routing
        "net.ipv4.conf.default.accept_source_route" = 0; # Disable source routing for default
        "net.ipv4.conf.all.arp_filter" = 1; # Enable ARP filtering
        "net.ipv4.conf.default.arp_filter" = 1; # Enable ARP filtering for default
        "net.ipv4.conf.all.log_martians" = 1; # Log packets with impossible addresses
        "net.ipv4.conf.default.log_martians" = 1; # Log packets with impossible addresses for default
        "net.ipv4.conf.all.accept_redirects" = 0; # Disable ICMP redirects
        "net.ipv4.conf.default.accept_redirects" = 0; # Disable ICMP redirects for default
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1; # Ignore bogus ICMP error responses
        "net.ipv4.conf.all.send_redirects" = 0; # Prevent sending of ICMP redirects
        "net.ipv4.conf.default.send_redirects" = 0; # Prevent sending of ICMP redirects for default
        "net.ipv4.tcp_syncookies" = 1; # Enable SYN cookies to protect against SYN flood attacks
        "net.ipv4.tcp_fin_timeout" = 15; # Reduce time that sockets stay in TIME_WAIT state
        "net.ipv4.tcp_keepalive_time" = 300; # Time between keepalive probes
        "net.ipv4.tcp_keepalive_intvl" = 60; # Interval between keepalive probes
        "net.ipv4.tcp_keepalive_probes" = 5; # Number of keepalive probes before declaring a connection dead
        "net.ipv4.tcp_max_syn_backlog" = 1024; # Maximum number of remembered connection requests
        "net.ipv4.tcp_max_tw_buckets" = 5000; # Maximum number of TIME_WAIT buckets
        "net.ipv4.tcp_tw_reuse" = 1; # Reuse TIME_WAIT sockets for new connections
        "net.ipv4.tcp_tw_recycle" = 0; # Disable TCP timestamp recycling
        "net.ipv4.tcp_rfc1337" = 1; # Mitigate TCP Time-Wait assassination hazards
        "net.ipv4.conf.all.secure_redirects" = 0; # Disable secure ICMP redirects
        "net.ipv4.conf.default.secure_redirects" = 0; # Disable secure ICMP redirects for default
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1; # Ignore ICMP echo requests to broadcast addresses

        # Memory Management
        "vm.swappiness" = 10; # Control the tendency of the kernel to swap
        "vm.dirty_ratio" = 10; # Percentage of system memory used before writing to disk
        "vm.dirty_background_ratio" = 5; # Percentage of system memory used before starting background writes
        "vm.overcommit_memory" = 1; # Allow the kernel to overcommit memory
        "vm.overcommit_ratio" = 50; # Percentage of RAM to be considered as committed
        "vm.min_free_kbytes" = 65536; # Minimum number of kilobytes of free memory

        # Security
        "kernel.dmesg_restrict" = 1; # Restrict dmesg access to root only
        "kernel.randomize_va_space" = 2; # Enable full address space randomization
        "kernel.pid_max" = 65536; # Maximum number of processes
        "kernel.kptr_restrict" = 1; # Restrict kernel pointer exposure
        "kernel.unprivileged_bpf_disabled" = 1; # Disable unprivileged BPF usage
        "kernel.sysrq" = 0; # Disable magic SysRq key
        "kernel.yama.ptrace_scope" = 2; # Restricted ptrace access

        # File Descriptors
        "fs.file-max" = 100000; # Maximum number of file descriptors
        "fs.protected_hardlinks" = 1; # Protect hardlinks
        "fs.protected_symlinks" = 1; # Protect symlinks
        "fs.suid_dumpable" = 0; # Disable core dumps for setuid binaries
        "fs.inotify.max_user_watches" = 524288; # Maximum number of inotify watches

        # Process Handling
        "kernel.sched_child_runs_first" = 0; # Child processes do not run before parent processes
        "kernel.sched_rr_timeslice_ms" = 100; # Time slice in milliseconds for round-robin scheduling

        # IPC
        "kernel.msgmax" = 65536; # Maximum size of a message in a message queue
        "kernel.msgmni" = 1024; # Maximum number of message queue identifiers
        "kernel.sem" = "250 256000 32 128"; # Semaphore settings
        "kernel.shmmax" = 68719476736; # Maximum size of a shared memory segment
        "kernel.shmall" = 4294967296; # Total amount of shared memory

        # Networking
        "net.ipv6.conf.all.disable_ipv6" = 1; # Disable IPv6
        "net.ipv6.conf.default.disable_ipv6" = 1; # Disable IPv6 for default
        "net.ipv6.conf.lo.disable_ipv6" = 1; # Disable IPv6 on the loopback interface
        "net.core.somaxconn" = 1024; # Maximum number of connections for the socket
        "net.core.netdev_max_backlog" = 5000; # Maximum number of packets allowed on the input queue
        "net.core.rmem_max" = 16777216; # Increase receive buffer size
        "net.core.wmem_max" = 16777216; # Increase send buffer size
        "net.core.optmem_max" = 40960; # Maximum memory used for options

        # Miscellaneous
        "kernel.panic" = 10; # Reboot 10 seconds after a panic
        "kernel.panic_on_oops" = 1; # Panic on kernel oops
        "vm.panic_on_oom" = 1; # Panic on out-of-memory
        "kernel.unprivileged_userns_clone" = 1; # For podman
    };
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
    dpi = 135;
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

  environment.systemPackages = with pkgs; [
    audit
    dive
    firefox
    git
    podman-compose
    podman-tui
    wget
    gnupg
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
    nodejs
    tree
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
    openssh.enable = false;
    syslogd.enable = true;
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
    chrony = {
      enable = true;
      servers = [
        "0.centos.pool.ntp.org"
        "1.centos.pool.ntp.org"
        "2.centos.pool.ntp.org"
        "3.centos.pool.ntp.org"
      ];
      enableNTS = true;
      extraConfig = ''
        ntsservercert /etc/chrony/nts/fullchain.pem
        ntsserverkey /etc/chrony/nts/key.pem
      '';
    };
    udev.packages = [ pkgs.yubikey-personalization ];
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
      u2f = {
        enable = true;
        interactive = true;
        cue = true;
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

  users.defaultUserShell = pkgs.bash;

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
    GDK_SCALE = "1.75";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    ELECTRON_ENABLE_LOGGING = "true";
    ELECTRON_USE_SCALE_FACTOR = "1.75"; # Adjust the scale factor as need
  };

  # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
  # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ 
      "${XDG_BIN_HOME}"
    ];
    
    # Make Firefox use xinput2 for better touchscreen support
    MOZ_USE_XINPUT2 = "1";
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
      enableSSHSupport = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };

    bash = {
      enableCompletion = true;
    };

    # Better shell prompt
    starship = {
      enable = true;
      settings = {
        username = {
          style_user = "blue bold";
          style_root = "red bold";
          format = "[$user]($style) ";
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          ssh_symbol = "🌐 ";
          format = "on [$hostname](bold red) ";
          trim_at = ".local";
          disabled = false;
        };
      };
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

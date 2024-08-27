{ config, pkgs, ... }:

{
 # Home Manager configuration for user 'last'
  home-manager.users.last = { pkgs, ... }: {
    home.packages = with pkgs; [
      alacritty
      btop
      cava
      feh
      fzf
      gnupg
      irssi
      keychain
      mpv
      ncmpcpp
      vscodium
      home-manager
      element-desktop
    ];

    home.file.".config/alacritty/catppuccin-frappe.toml" = {
      source = /etc/nixos/themes/alacritty/catppuccin-frappe.toml;
    };

    home.file.".config/btop/themes/catppuccin_frappe.theme" = {
      source = /etc/nixos/themes/btop/themes/catppuccin_frappe.theme;
    };

    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        historyControl = [ "ignoredups" ];
        historyFile = "~/.bash_history";
        historySize = 250000;
        shellAliases.ll = "ls -l";
      };
      alacritty = {
        enable = true;
        settings = {
          import = "~/.config/alacritty/catppuccin-frappe.toml";
        };
      };
      btop = {
        enable = true;
        settings = {
          color_theme = "catppuccin_frappe";
          theme_background = true;
        };
      };
      cava = {
        enable = true;
        settings = {
          general.framerate = 60;
          input.method = "alsa";
          smoothing.noise_reduction = 88;
          color = {
            background = "#303446";
            gradient = 1;
            gradient_color_1 = "#81c8be";
            gradient_color_2 = "#99d1db";
            gradient_color_3 = "#85c1dc";
            gradient_color_4 = "#8caaee";
            gradient_color_5 = "#ca9ee6";
            gradient_color_6 = "#f4b8e4";
            gradient_color_7 = "#ea999c";
            gradient_color_8 = "#e78284";
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
          catppuccin.catppuccin-vsc-icons
        ];
      };
    };

    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
    home.stateVersion = "24.05"; # This is the Home Manager version
  };
}

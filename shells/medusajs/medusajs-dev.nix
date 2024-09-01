# This is the shell.nix file for setting up a Node.js development environment with MedusaJS.
# It includes the necessary dependencies like Node.js, Yarn, PostgreSQL, Redis, and Docker.

{ pkgs ? import <nixpkgs> {} }:

let
  # Define the directory where the docker-compose.yml is located
  projectDir = "/etc/nixos/shells/medusajs";

in pkgs.mkShell {
  # Define the build inputs needed for the development environment.
  buildInputs = [
    pkgs.nodejs-18_x  # Node.js 18.x for running the Medusa server
    pkgs.yarn         # Yarn package manager
    pkgs.postgresql   # PostgreSQL for the database
    pkgs.redis        # Redis for event queues
    pkgs.vscodium     # VS Codium as the editor
    pkgs.docker       # Docker for containerized services
    pkgs.docker-compose # Docker Compose for managing multi-container Docker applications
    pkgs.socat        # socat is required for rootless Docker mode
  ];

  # The shellHook runs when you enter the shell.
  shellHook = ''
    echo "Welcome to the MedusaJS development environment!";

    # Ensure Docker daemon is running in rootless mode
    if ! pgrep -x "dockerd" > /dev/null; then
      echo "Starting Docker daemon in rootless mode..."
      dockerd-rootless.sh &
      sleep 5  # Give the Docker daemon a moment to start
    fi

    # Start Docker Compose using the correct directory
    if [ -f ${projectDir}/docker-compose.yml ]; then
      echo "Starting Docker Compose services..."
      docker-compose -f ${projectDir}/docker-compose.yml up -d
    fi

    export NODE_ENV="development";
  '';

  # The exitHook runs when you leave the shell.
  exitHook = ''
    # Stop Docker Compose using the correct directory
    if [ -f ${projectDir}/docker-compose.yml]; then
      echo "Stopping Docker Compose services...";
      docker-compose -f ${projectDir}/docker-compose.yml down
    fi

    # Stop Docker daemon if it was started by this shell
    if pgrep -x "dockerd-rootless" > /dev/null; then
      echo "Stopping Docker daemon..."
      pkill dockerd-rootless.sh
    fi
  '';
}


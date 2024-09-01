# This is the shell.nix file for setting up a Node.js development environment with MedusaJS.
# It includes the necessary dependencies like Node.js, Yarn, PostgreSQL, Redis, and Docker.

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Define the build inputs needed for the development environment.
  buildInputs = [
    pkgs.nodejs-18_x  # Node.js 18.x for running the Medusa server
    pkgs.yarn         # Yarn package manager
    pkgs.postgresql   # PostgreSQL for the database
    pkgs.redis        # Redis for event queues
    pkgs.vscodium     # VS Codium as the editor
    pkgs.docker       # Docker for containerized services
    pkgs.docker-compose # Docker Compose for managing multi-container Docker applications
  ];

  # The shellHook runs when you enter the shell.
  shellHook = ''
    echo "Welcome to the MedusaJS development environment!";

    # Start Docker Compose
    if [ -f docker-compose.yml ]; then
      echo "Starting Docker Compose services..."
      docker-compose up -d
    fi

    export NODE_ENV="development";
  '';

  # The exitHook runs when you leave the shell.
  exitHook = ''
    # Stop Docker Compose
    if [ -f docker-compose.yml ]; then
      echo "Stopping Docker Compose services...";
      docker-compose down
    fi
  '';
}


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
  ];

  # The shellHook runs when you enter the shell.
  shellHook = ''
    echo "Welcome to the MedusaJS development environment!";
    export NODE_ENV="development";
  '';
}


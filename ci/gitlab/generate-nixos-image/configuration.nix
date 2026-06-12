{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ vim ];

  system.stateVersion = "26.05";
}

{
  pkgs,
  rubyNix,
  bundixcli,
}:
pkgs.mkShell {
  packages =
    [ bundixcli ]
    ++ (with rubyNix; [
      ruby
      env
    ])
    ++ (with pkgs; [
      nil
      nixfmt-rfc-style
    ]);
}

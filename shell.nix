{
  pkgs,
  rubyNix,
}:
pkgs.mkShell {
  packages =
    (with rubyNix; [
      ruby
      env
    ])
    ++ (with pkgs; [
      nil
      nixfmt-rfc-style
    ]);
}

{
  pkgs,
  rubyNix,
  formatter,
}:
pkgs.mkShellNoCC {
  packages =
    (with rubyNix; [
      ruby
      env
    ])
    ++ (with pkgs; [
      xpdf
      nil
      formatter
      actionlint
      pnpm
    ]);
}

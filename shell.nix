{
  pkgs,
  rubyNix,
  formatter,
}:
pkgs.mkShell {
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
    ]);
}

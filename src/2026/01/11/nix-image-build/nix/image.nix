{
  pkgs,
  tag ? "latest",
  app ? pkgs.hello,
}:
pkgs.dockerTools.buildImage {
  name = "app";
  inherit tag;
  created = "now";
  copyToRoot =
    pkgs.buildEnv {
      name = "app-root";
      extraPrefix = "/usr/local";
      paths = [ app ];
    };
  config = {
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [
      "${pkgs.dumb-init}/bin/dumb-init"
      "--"
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
  compressor = "zstd";
}

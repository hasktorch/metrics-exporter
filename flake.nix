{
  description = "tensorboard-exporter";

  nixConfig = {
    substituters = [
      https://cache.nixos.org
    ];
    bash-prompt = "\[nix-develop(tensorboard-exporter)\]$ ";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          myPython = pkgs.python39.withPackages (ps: with ps;
            [ opencv4
              pillow
              pytorch-bin
              tensorflow-tensorboard
              numpy
              pandas
              fire
              keras
              ijson
              scikitimage
              tqdm
            ]
          );
      in
        rec {
          packages = flake-utils.lib.flattenTree {
            tensorboard = pkgs.python39Packages.tensorflow-tensorboard;
            tensorboard-exporter = pkgs.stdenv.mkDerivation {
              pname = "tensorboard-exporter";
              version = "0.1";
              buildInputs = [myPython];
              src = ./.;
              installPhase = ''
              mkdir -p $out/bin
              cp src/csv-exporter.py $out/bin
              cp src/torchscript-exporter.py $out/bin
              chmod +x $out/bin/*
              '';
            };
          };
          defaultPackage = packages.tensorboard-exporter;
          devShell = pkgs.mkShell {
            packages = with pkgs; [ myPython ];
            shellHook = ''
            export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
            #export REQUESTS_CA_BUNDLE=""
            export TRANSFORMERS_CACHE=$TMPDIR
            export XDG_CACHE_HOME=$TMPDIR
            
            export PIP_PREFIX=$(pwd)/_build/pip_packages
            export PYTHONPATH="$PIP_PREFIX/${myPython.sitePackages}:$PYTHONPATH"
            export PATH="$PIP_PREFIX/bin:$PATH"
            unset SOURCE_DATE_EPOCH
            pwd
            mkdir -p $TMP/output
          '';
            inputsFrom = builtins.attrValues self.packages.${system};
          };
        }
    );
}

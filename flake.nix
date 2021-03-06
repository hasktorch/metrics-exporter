{
  description = "tensorboard-exporter";

  nixConfig = {
    substituters = [
      https://cache.nixos.org
    ];
    bash-prompt = "\[nix-develop(tensorboard-exporter)\]$ ";
  };

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flamegraph-src = {
      url = "github:brendangregg/FlameGraph";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flamegraph-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          flamegraph = pkgs.stdenv.mkDerivation {
            pname = "framegraph";
            version = "0.1";
            buildInputs = [pkgs.perl];
            src = flamegraph-src;
            installPhase = ''
              mkdir -p $out/bin
              cp *.pl $out/bin/
            '';
          };
          docker-pycreds = with pkgs.python3Packages;
            buildPythonPackage rec {
              pname = "docker-pycreds";
              version = "0.4.0";
              src = builtins.fetchurl {
                name = "docker_pycreds-0.4.0-py2.py3-none-any.whl";
                url = "https://files.pythonhosted.org/packages/f5/e8/f6bd1eee09314e7e6dee49cbe2c5e22314ccdb38db16c9fc72d2fa80d054/docker_pycreds-0.4.0-py2.py3-none-any.whl";
                sha256 = "0jdg6wynr0lvw4l2m4fmnz9049vj1p6ikv06a406hy32d0j12rkj";
              };
              format = "wheel";
              doCheck = false;
              propagatedBuildInputs = [six];
            };
          wandb = with pkgs.python3Packages;
            buildPythonPackage rec {
              pname = "wandb";
              version = "0.12.10";
              src = builtins.fetchurl {
                name = "wandb-0.12.10-py2.py3-none-any.whl";
                url = "https://files.pythonhosted.org/packages/05/39/d73e9a767184e0e1798255aed78e05ed4ebe988c0552f9abd36127dc2c53/wandb-0.12.10-py2.py3-none-any.whl";
                sha256 = "07frmiq712nsphs3wj8n1hdssd9z64dp6m23m9ydpzl7fcn2y6px";
              };
              format = "wheel";
              doCheck = false;
              propagatedBuildInputs = [
                click
                shortuuid
                sentry-sdk
                requests
                docker-pycreds
                dateutil
                GitPython
                promise
                pyyaml
                psutil
                protobuf
                yaspin
                pathtools
                setuptools
              ];
            };
          nvidia-ml-py3 =
            let pname = "nvidia-ml-py3";
                version = "7.352.0";
            in with pkgs.python3Packages;
              buildPythonPackage rec {
                inherit pname;
                inherit version;
                src = fetchPypi {
                  inherit pname;
                  inherit version;
                  hash = "sha256-OQ8CkZ7p1z/mOpjHMQEGGms3+mlKeTq/VmczIPH1Enc=";
                };
                format = "setuptools";
                doCheck = false;
                propagatedBuildInputs = [
                ];
              };
          everett =
            let pname = "everett";
                version = "3.0.0";
            in with pkgs.python3Packages;
              buildPythonPackage rec {
                inherit pname;
                inherit version;
                src = fetchPypi {
                  inherit pname;
                  inherit version;
                  hash = "sha256-gM5ZIWjOUGQ3Eezv8+yU/e7HVfIo3nRvILG/yU6iBoI=";
                };
                format = "setuptools";
                doCheck = false;
                propagatedBuildInputs = [
                ];
              };
          comet-ml = with pkgs.python3Packages;
            buildPythonPackage rec {
              pname = "comet-ml";
              version = "3.26.0";
              src = builtins.fetchurl {
                name = "comet_ml-3.26.0-py2.py3-none-any.whl";
                url = "https://files.pythonhosted.org/packages/5f/02/3106fa0bd37d0cd51b7651d8d34d2f91b8bfb3e4ee8ef2d6862865bbfa3c/comet_ml-3.26.0-py2.py3-none-any.whl";
                sha256 = "1sh226prngvzb6d2yfivhzf4cpm94v1fkvs6kki6izifzvxdlr5z";
              };
              format = "wheel";
              doCheck = false;
              propagatedBuildInputs = [
                wurlitzer
                wrapt
                websocket-client
                nvidia-ml-py3
                semantic-version
                dulwich
                requests
                jsonschema
                requests-toolbelt
                everett
                configobj
                setuptools
              ];
            };
          myPython = pkgs.python39.withPackages (ps: with ps;
            [ pytorch-bin
              tensorflow-tensorboard
              numpy
              pandas
              wandb
              comet-ml
            ]
          );
      in
        rec {
          packages = flake-utils.lib.flattenTree {
            inherit flamegraph;
            tensorboard = pkgs.python39Packages.tensorflow-tensorboard;
            inherit wandb;
            inherit comet-ml;
            metrics-exporter = pkgs.stdenv.mkDerivation {
              pname = "metrics-exporter";
              version = "0.1";
              buildInputs = [myPython];
              src = ./.;
              installPhase = ''
              mkdir -p $out/bin
              cp src/*.py $out/bin
              chmod +x $out/bin/*
              '';
            };
          };
          defaultPackage = packages.metrics-exporter;
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

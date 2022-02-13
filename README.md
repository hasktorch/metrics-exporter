# Metrics Exporter

# Install from source code

```
git clone git@github.com:hasktorch/metrics-exporter.git
cd metrics-exporter
nix profile install .#tensorboard
nix profile install .#wandb
nix profile install .#

# or 

git clone git@github.com:hasktorch/metrics-exporter.git
cd metrics-exporter
nix profile install github:metrics-exporter#tensorboard
nix profile install github:metrics-exporter#wandb
nix profile install github:metrics-exporter#
```



# Usage

## Export a CSV file to tensorboard

```
csv-to-tensorboard.py --csv-path sample/log.csv
```

## Export a CSV file to WandB

```
wandb login
csv-to-wandb.py --project test-project --csv-path sample/log.csv
```

## Export a torchscript file to tensorboard

```
torchscript-to-tensorboard.py --torchscript sample/yolov5s.torchscript.pt --input-shape '[3,640,480]'
```


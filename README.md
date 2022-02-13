# Metrics Exporter

# Install from source code

```
nix profile install .#tensorboard
nix profile install .#wandb
nix profile install .#
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


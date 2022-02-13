#!/usr/bin/env python

import pandas as pd
import wandb

def get_args_parser(add_help=True):
    import argparse
    parser = argparse.ArgumentParser(description='Export CSV to WandB', add_help=add_help)
    parser.add_argument('--csv-path', default=None, help='a log file of CSV format')
    parser.add_argument('--project', default=None, help='Project Name')
    return parser

def main(args):
    log = pd.read_csv(args.csv_path)
    wandb.init(project=args.project)
    for i, v in log.iterrows():
        wandb.log({'epoch': v["epoch"], v["type"]: float(v["value"])})
    wandb.finish()

if __name__ == "__main__":
    args = get_args_parser().parse_args()
    main(args)

#!/usr/bin/env python

import pandas as pd
from torch.utils.tensorboard import SummaryWriter

def get_args_parser(add_help=True):
    import argparse
    parser = argparse.ArgumentParser(description='Export CSV to Tensorboard', add_help=add_help)
    parser.add_argument('--csv-path', default=None, help='a log file of CSV format')
    return parser

def main(args):
    writer = SummaryWriter()
    log = pd.read_csv(args.csv_path)
    
    for i, v in log.iterrows():
        writer.add_scalar(v["type"], float(v["value"]), v["epoch"])

    writer.flush()

if __name__ == "__main__":
    args = get_args_parser().parse_args()
    main(args)

#!/usr/bin/env python

import pandas as pd
from torch.utils.tensorboard import SummaryWriter

def get_args_parser(add_help=True):
    import argparse
    parser = argparse.ArgumentParser(description='Export a metric to Tensorboard', add_help=add_help)
    parser.add_argument('--logdir', default=None, help='Save directory location. Default is runs/**CURRENT_DATETIME_HOSTNAME**,')
    parser.add_argument('--epoch', default=None, help='Current epoch')
    parser.add_argument('--type', default=None, help='Metric type')
    parser.add_argument('--value', default=None, help='Metric value')
    parser.add_argument('otherthings', nargs='*')
    return parser

def main(args):
    writer = SummaryWriter(args.logdir)
    writer.add_scalar(args.type, float(args.value), args.epoch)
    writer.flush()

if __name__ == "__main__":
    args = get_args_parser().parse_args()
    main(args)

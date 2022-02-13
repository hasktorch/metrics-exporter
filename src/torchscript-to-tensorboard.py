#!/usr/bin/env python

import pandas as pd
from torch.utils.tensorboard import SummaryWriter
import torch

def get_args_parser(add_help=True):
    import argparse
    parser = argparse.ArgumentParser(description='Export TorchScript to Tensorboard', add_help=add_help)
    parser.add_argument('--torchscript', default=None, help='a model file of TorchScript')
    parser.add_argument('--input-shape', default=None, help='shape of input-tensor for a model')
    return parser

def main(args):
    writer = SummaryWriter()
    model = torch.jit.load(args.torchscript)
    writer.add_graph(model,eval("torch.zeros("+ args.input_shape + ")"))
    writer.flush()

if __name__ == "__main__":
    args = get_args_parser().parse_args()
    main(args)

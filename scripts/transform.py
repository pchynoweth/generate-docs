import asyncio
import argparse
import os
import sys
import importlib

parser = argparse.ArgumentParser(description='File transformer')
parser.add_argument('--input', '-i', type=str, required=True)
parser.add_argument('--output', '-o', type=str)
args = parser.parse_args()

def transform(handler) -> None:
    if hasattr(handler, 'generator'):
        for line in handler.generator():
            return line
    elif hasattr(handler, 'dump'):
        return handler.dump()
    elif hasattr(handler, 'coroutine'):
        async def runner(task):
            return await task
        return asyncio.run(runner(handler.coroutine()))
    else:
        raise ValueError('Unsupported handler')

if args.output is None:
    args.output, _ = os.path.splitext(args.input)

spec = importlib.util.spec_from_file_location(args.output, args.input)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with open(args.output, 'w') as f:
    f.write(transform(module))
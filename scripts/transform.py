import asyncio
import argparse
import os
import sys
import importlib
import yaml

parser = argparse.ArgumentParser(description='File transformer')
parser.add_argument('--input', '-i', type=str, required=True)
parser.add_argument('--output', '-o', type=str)
args = parser.parse_args()

def transform(handler) -> None:
    if not hasattr(handler, 'frontmatter'):
        raise ValueError('All docs must contain frontmatter')
    fm = handler.frontmatter()
    metadata = '---\n' + yaml.dump(fm) + '---'
    chunks = [ metadata ]
    if hasattr(handler, 'generator'):
        for line in handler.generator():
            chunks.append(line)
    elif hasattr(handler, 'dump'):
        chunks.append(handler.dump())
    elif hasattr(handler, 'coroutine'):
        async def runner(task):
            return await task
        chunks.append(asyncio.run(runner(handler.coroutine())))
    else:
        raise ValueError('Unsupported handler')

    return '\n'.join(chunks)

if args.output is None:
    args.output, _ = os.path.splitext(args.input)

spec = importlib.util.spec_from_file_location(args.output, args.input)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with open(args.output, 'w') as f:
    f.write(transform(module))
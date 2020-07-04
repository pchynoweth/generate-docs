from typing import Generator

def frontmatter() -> dict:
    return {
        'title': 'Generator'
    }

def generator() -> Generator[str, None, None]:
    yield 'This is a test generator'
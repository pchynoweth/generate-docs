from typing import Generator

def generator() -> Generator[str, None, None]:
    yield 'This is a test generator'
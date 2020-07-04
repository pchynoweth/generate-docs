import asyncio

def frontmatter() -> dict:
    return {
        'title': 'Cooroutine generator'
    }

async def coroutine() -> str:
    await asyncio.sleep(1)
    return 'this is a test coroutine'
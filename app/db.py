from fastapi import HTTPException, status
from .config import settings

import asyncpg
import json
from typing import Any, Text, Optional


DSN = settings.dsn

PGPOOL = None


async def get_pool():
    global PGPOOL
    if not PGPOOL:
        PGPOOL = await asyncpg.create_pool(dsn=DSN, command_timeout=60, max_size=20)
    return PGPOOL


async def pg_fetch(pool, sql: Text, *args: Optional[Any]):
    conn = await pool.acquire()
    await conn.set_type_codec(
        'jsonb',
        encoder=json.dumps,
        decoder=json.loads,
        schema='pg_catalog'
    )
    try:
        res = await conn.fetch(sql,*args)
        res = [dict(el) for el in res]

        if len(res) == 0:
            return None
        if len(res) == 1:
            return res[0]
        else:
            return res
    except Exception as error:
        print(error)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={'detail': 'Invalid input'})
    finally:
        await pool.release(conn)

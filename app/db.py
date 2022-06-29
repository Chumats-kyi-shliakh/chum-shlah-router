from fastapi import HTTPException, status
from .config import settings

import asyncpg
import json
from typing import Any, Text, Optional

import time


DSN = settings.dsn
PGPOOL = None


async def jsonb_codec(conn):
    await conn.set_type_codec(
        'jsonb',
        encoder=json.dumps,
        decoder=json.loads,
        schema='pg_catalog'
    )


async def get_pool():
    global PGPOOL
    if not PGPOOL:
        PGPOOL = await asyncpg.create_pool(dsn=DSN, command_timeout=60, max_size=20, init=jsonb_codec)
    return PGPOOL


async def pg_fetch(pool, sql: Text, *args: Optional[Any]):

    conn = await pool.acquire()

    try:
        start_time = time.time()

        res = await conn.fetch(sql, *args)
        res = [dict(el) for el in res]

        print(
            f'Return res | time: { time.time() - start_time} s.\nIDE conn {pool.get_idle_size()}')

        if len(res) == 0:
            return None
        else:
            return res
    except Exception as error:
        print(error)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={'detail': 'Invalid input'})
    finally:
        await pool.release(conn)

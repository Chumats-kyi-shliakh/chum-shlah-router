from fastapi import status, APIRouter, HTTPException, Depends

from ..db import get_pool, pg_fetch
from .. import schemas

router = APIRouter()



@router.get('/delivery-list', status_code=status.HTTP_200_OK)
async def get_delivery(lng: float = 28.66468, lat: float = 50.26009, pgpool=Depends(get_pool)):

    sql_q = """--sql
        SELECT cp_GetNerestOrders($1, $2)
        """

    res = await pg_fetch(pgpool, sql_q, lng, lat)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]


@router.get('/directions', status_code=status.HTTP_200_OK)
async def get_delivery(origin: str = '28.66468,50.26009', destination: str = '30.11233,49.79832', pgpool=Depends(get_pool)):

    lng1, lat1 = origin.split(',')
    lng2, lat2 = destination.split(',')

    sql_q = """--sql
        SELECT cp_FromAtoB($1, $2, $3, $4)
        """

    res = await pg_fetch(pgpool, sql_q, lng1, lat1, lng2, lat2)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]


@router.post('/tcp-route', status_code=status.HTTP_200_OK)
async def get_delivery(q: schemas.RouteQuery, pgpool=Depends(get_pool)):

    sql_q = """--sql
        SELECT cp_TCProute($1, $2, $3, $4)
        """

    res = await pg_fetch(pgpool, sql_q, q.longitude, q.latitude, q.storage_ids, q.order_ids)

    if not res:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return res[0]

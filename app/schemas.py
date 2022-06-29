from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import date, datetime, time, timedelta
from uuid import UUID


class RouteQuery(BaseModel):
    longitude: float = 28.66468
    latitude: float = 50.26009
    storage_ids: List[int] = [4378, 3914, 4008]
    order_ids: List[UUID] = ['f1bb12f0-8e39-4846-a532-e7c2aaf1731a', 'c920831a-ef35-4d54-8587-765cca60832f',
                             '543870d0-3609-4e0d-a346-797cc1c814ae', 'c3834b6f-8330-4327-8de8-f98b8f3ac04f']

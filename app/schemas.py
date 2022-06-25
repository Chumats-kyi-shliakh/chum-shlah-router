from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import date, datetime, time, timedelta
from uuid import UUID


class RouteQuery(BaseModel):
    longitude: float = 28.66468
    latitude: float = 50.26009
    storage_ids: List[int] = [4378, 3914, 4008]
    order_ids: List[UUID] = ['b8144902-fb7d-44db-9842-a3df79a7b88e',
                             '9a134cba-092d-4ac6-ba19-6130f73b51df',
                              '31a84b4b-cfc7-48a3-9ad4-8695f71a9ab9']

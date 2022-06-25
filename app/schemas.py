from pydantic import BaseModel
from typing import Optional, List, Dict
from datetime import date, datetime, time, timedelta
from uuid import UUID


class UserLogim(BaseModel):
    usr_login: str
    usr_password: str


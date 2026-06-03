from datetime import datetime
from typing import Annotated
from uuid import UUID

from pydantic import BeforeValidator


def _str_from_uuid(v: object) -> str:
    return str(v)


def _str_from_dt(v: object) -> str:
    if isinstance(v, datetime):
        return v.isoformat()
    return str(v)


UuidStr = Annotated[str, BeforeValidator(_str_from_uuid)]
DatetimeStr = Annotated[str, BeforeValidator(_str_from_dt)]

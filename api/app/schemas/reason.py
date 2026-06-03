from pydantic import BaseModel, ConfigDict

from app.schemas import DatetimeStr, UuidStr


class ReasonCreate(BaseModel):
    label: str


class ReasonUpdate(BaseModel):
    label: str


class ReasonResponse(BaseModel):
    id: UuidStr
    parent_id: UuidStr
    label: str
    created_at: DatetimeStr

    model_config = ConfigDict(from_attributes=True)

from datetime import date

from pydantic import BaseModel, ConfigDict

from app.schemas import DatetimeStr, UuidStr


class ChildCreate(BaseModel):
    name: str
    age: int
    birthday: date
    image_url: str | None = None
    pin: str


class ChildUpdate(BaseModel):
    name: str | None = None
    age: int | None = None
    birthday: date | None = None
    image_url: str | None = None


class ChildPinUpdate(BaseModel):
    pin: str


class ChildFcmTokenUpdate(BaseModel):
    fcm_token: str


class ChildResponse(BaseModel):
    id: UuidStr
    parent_id: UuidStr
    name: str
    age: int
    birthday: date
    image_url: str | None
    balance: float
    created_at: DatetimeStr

    model_config = ConfigDict(from_attributes=True)

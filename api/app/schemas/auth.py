from pydantic import BaseModel

from app.schemas import UuidStr


class ChildLoginRequest(BaseModel):
    child_id: str
    pin: str


class ChildBalanceResponse(BaseModel):
    child_id: UuidStr
    name: str
    balance: float

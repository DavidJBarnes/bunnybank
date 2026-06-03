from pydantic import BaseModel, ConfigDict

from app.schemas import DatetimeStr, UuidStr


class TransactionResponse(BaseModel):
    id: UuidStr
    child_id: UuidStr
    reason_id: UuidStr
    amount: float
    created_at: DatetimeStr

    model_config = ConfigDict(from_attributes=True)

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_parent
from app.models.parent import Parent
from app.services.money import send_money

router = APIRouter(prefix="/send-money", tags=["money"])


class SendMoneyRequest(BaseModel):
    child_ids: list[uuid.UUID]
    amount: float
    reason_id: uuid.UUID


class SendMoneyResponse(BaseModel):
    message: str
    transactions_count: int


@router.post("", response_model=SendMoneyResponse)
async def send_money_endpoint(
    body: SendMoneyRequest,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Parent).where(Parent.id == parent_id))
    if not result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired. Please log in again.",
        )

    if body.amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Amount must be positive"
        )

    try:
        transactions = await send_money(
            db=db,
            parent_id=parent_id,
            child_ids=body.child_ids,
            amount=body.amount,
            reason_id=body.reason_id,
        )
        return SendMoneyResponse(
            message="Money sent successfully",
            transactions_count=len(transactions),
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_child
from app.models.child import Child
from app.models.transaction import Transaction
from app.schemas.auth import ChildBalanceResponse, ChildLoginRequest
from app.schemas.transaction import TransactionResponse
from app.services.auth import create_child_token, verify_password

router = APIRouter(prefix="/child", tags=["child"])


@router.post("/login")
async def child_login(body: ChildLoginRequest, db: AsyncSession = Depends(get_db)):
    try:
        child_id = uuid.UUID(body.child_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid child ID"
        )

    result = await db.execute(select(Child).where(Child.id == child_id))
    child = result.scalar_one_or_none()
    if not child or not verify_password(body.pin, child.pin_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid PIN"
        )

    token = create_child_token(child.id)
    return {"access_token": token, "token_type": "bearer", "child_name": child.name}


@router.get("/balance", response_model=ChildBalanceResponse)
async def get_balance(
    child_id: uuid.UUID = Depends(get_current_child),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Child).where(Child.id == child_id))
    child = result.scalar_one()
    return ChildBalanceResponse(
        child_id=str(child.id),
        name=child.name,
        balance=float(child.balance),
    )


@router.get("/transactions", response_model=list[TransactionResponse])
async def get_transactions(
    child_id: uuid.UUID = Depends(get_current_child),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Transaction)
        .where(Transaction.child_id == child_id)
        .order_by(Transaction.created_at.desc())
        .limit(50)
    )
    return result.scalars().all()

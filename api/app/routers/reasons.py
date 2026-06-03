import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_parent
from app.models.parent import Parent
from app.models.reason import Reason
from app.schemas.reason import ReasonCreate, ReasonResponse, ReasonUpdate

router = APIRouter(prefix="/reasons", tags=["reasons"])


async def _verify_parent_exists(db: AsyncSession, parent_id: uuid.UUID) -> Parent:
    result = await db.execute(select(Parent).where(Parent.id == parent_id))
    parent = result.scalar_one_or_none()
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired. Please log in again.",
        )
    return parent


@router.get("", response_model=list[ReasonResponse])
async def list_reasons(
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Reason).where(Reason.parent_id == parent_id))
    return result.scalars().all()


@router.post("", response_model=ReasonResponse, status_code=status.HTTP_201_CREATED)
async def create_reason(
    body: ReasonCreate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    await _verify_parent_exists(db, parent_id)
    reason = Reason(
        id=uuid.uuid4(),
        parent_id=parent_id,
        label=body.label,
    )
    db.add(reason)
    await db.commit()
    await db.refresh(reason)
    return reason


@router.put("/{reason_id}", response_model=ReasonResponse)
async def update_reason(
    reason_id: uuid.UUID,
    body: ReasonUpdate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Reason).where(Reason.id == reason_id, Reason.parent_id == parent_id)
    )
    reason = result.scalar_one_or_none()
    if not reason:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Reason not found"
        )

    reason.label = body.label
    await db.commit()
    await db.refresh(reason)
    return reason


@router.delete("/{reason_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_reason(
    reason_id: uuid.UUID,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        delete(Reason).where(Reason.id == reason_id, Reason.parent_id == parent_id)
    )
    if result.rowcount == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Reason not found"
        )
    await db.commit()

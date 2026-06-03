import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_parent
from app.models.child import Child
from app.models.parent import Parent
from app.schemas.child import (
    ChildCreate,
    ChildPinUpdate,
    ChildFcmTokenUpdate,
    ChildResponse,
    ChildUpdate,
)
from app.services.auth import hash_password

router = APIRouter(prefix="/children", tags=["children"])


async def _verify_parent_exists(db: AsyncSession, parent_id: uuid.UUID) -> Parent:
    result = await db.execute(select(Parent).where(Parent.id == parent_id))
    parent = result.scalar_one_or_none()
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired. Please log in again.",
        )
    return parent


@router.get("", response_model=list[ChildResponse])
async def list_children(
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    await _verify_parent_exists(db, parent_id)
    result = await db.execute(select(Child).where(Child.parent_id == parent_id))
    return result.scalars().all()


@router.post("", response_model=ChildResponse, status_code=status.HTTP_201_CREATED)
async def create_child(
    body: ChildCreate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    await _verify_parent_exists(db, parent_id)
    child = Child(
        id=uuid.uuid4(),
        parent_id=parent_id,
        name=body.name,
        age=body.age,
        birthday=body.birthday,
        image_url=body.image_url,
        pin_hash=hash_password(body.pin),
    )
    db.add(child)
    await db.commit()
    await db.refresh(child)
    return child


@router.put("/{child_id}", response_model=ChildResponse)
async def update_child(
    child_id: uuid.UUID,
    body: ChildUpdate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Child not found"
        )

    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(child, key, value)

    await db.commit()
    await db.refresh(child)
    return child


@router.delete("/{child_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_child(
    child_id: uuid.UUID,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        delete(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    if result.rowcount == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Child not found"
        )
    await db.commit()


@router.put("/{child_id}/pin", response_model=ChildResponse)
async def update_child_pin(
    child_id: uuid.UUID,
    body: ChildPinUpdate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Child not found"
        )

    child.pin_hash = hash_password(body.pin)
    await db.commit()
    await db.refresh(child)
    return child


@router.put("/{child_id}/fcm-token", response_model=ChildResponse)
async def update_fcm_token(
    child_id: uuid.UUID,
    body: ChildFcmTokenUpdate,
    parent_id: uuid.UUID = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Child).where(Child.id == child_id, Child.parent_id == parent_id)
    )
    child = result.scalar_one_or_none()
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Child not found"
        )

    child.fcm_token = body.fcm_token
    await db.commit()
    await db.refresh(child)
    return child

import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.parent import Parent
from app.schemas.parent import (
    ParentLogin,
    ParentRegister,
    ParentResponse,
    TokenResponse,
)
from app.services.auth import create_parent_token, hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED
)
async def register(body: ParentRegister, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(Parent).where(Parent.email == body.email))
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, detail="Email already registered"
        )

    parent = Parent(
        id=uuid.uuid4(),
        name=body.name,
        email=body.email,
        hashed_password=hash_password(body.password),
    )
    db.add(parent)
    await db.commit()
    await db.refresh(parent)

    token = create_parent_token(parent.id)
    return TokenResponse(
        access_token=token,
        parent=ParentResponse.model_validate(parent),
    )


@router.post("/login", response_model=TokenResponse)
async def login(body: ParentLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Parent).where(Parent.email == body.email))
    parent = result.scalar_one_or_none()
    if not parent or not verify_password(body.password, parent.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password"
        )

    token = create_parent_token(parent.id)
    return TokenResponse(
        access_token=token,
        parent=ParentResponse.model_validate(parent),
    )

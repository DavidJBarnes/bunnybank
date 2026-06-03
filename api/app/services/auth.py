import uuid
from datetime import datetime, timedelta, timezone

from jose import jwt
from passlib.context import CryptContext

from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

PARENT_SCOPE = "parent"
CHILD_SCOPE = "child"


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(
    subject: str, scope: str, expires_delta: timedelta | None = None
) -> str:
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.jwt_expire_minutes)
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode = {"sub": subject, "scope": scope, "exp": expire}
    return jwt.encode(to_encode, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def create_parent_token(parent_id: uuid.UUID) -> str:
    return create_access_token(str(parent_id), PARENT_SCOPE)


def create_child_token(child_id: uuid.UUID) -> str:
    return create_access_token(str(child_id), CHILD_SCOPE)


def decode_token(token: str) -> dict:
    return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])

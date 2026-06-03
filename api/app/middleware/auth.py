import uuid

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError

from app.services.auth import PARENT_SCOPE, CHILD_SCOPE, decode_token

security = HTTPBearer()


async def get_current_parent(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> uuid.UUID:
    try:
        payload = decode_token(credentials.credentials)
        if payload.get("scope") != PARENT_SCOPE:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token scope"
            )
        return uuid.UUID(payload["sub"])
    except (JWTError, ValueError) as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        ) from e


async def get_current_child(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> uuid.UUID:
    try:
        payload = decode_token(credentials.credentials)
        if payload.get("scope") != CHILD_SCOPE:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Invalid token scope"
            )
        return uuid.UUID(payload["sub"])
    except (JWTError, ValueError) as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        ) from e

from pydantic import BaseModel, ConfigDict, EmailStr

from app.schemas import UuidStr


class ParentRegister(BaseModel):
    name: str
    email: EmailStr
    password: str


class ParentLogin(BaseModel):
    email: EmailStr
    password: str


class ParentResponse(BaseModel):
    id: UuidStr
    name: str
    email: str

    model_config = ConfigDict(from_attributes=True)


class ParentUpdate(BaseModel):
    name: str | None = None
    email: EmailStr | None = None
    password: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    parent: ParentResponse

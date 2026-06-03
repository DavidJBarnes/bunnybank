import asyncio
import uuid
from typing import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.database import Base, get_db
from app.main import app
from app.models.parent import Parent
from app.models.child import Child
from app.models.reason import Reason
from app.services.auth import hash_password

TEST_DATABASE_URL = (
    "postgresql+asyncpg://bunnybank:bunnybank@localhost:5432/bunnybank_test"
)


@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture(scope="session")
async def engine():
    engine = create_async_engine(TEST_DATABASE_URL, echo=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest_asyncio.fixture
async def db(engine) -> AsyncGenerator[AsyncSession, None]:
    session_factory = async_sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    async with session_factory() as session:
        yield session


@pytest_asyncio.fixture
async def client(db: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    async def override_get_db():
        yield db

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def parent(db: AsyncSession) -> Parent:
    parent = Parent(
        id=uuid.uuid4(),
        name="Test Parent",
        email="parent@test.com",
        hashed_password=hash_password("password123"),
    )
    db.add(parent)
    await db.commit()
    await db.refresh(parent)
    return parent


@pytest_asyncio.fixture
async def child(db: AsyncSession, parent: Parent) -> Child:
    child = Child(
        id=uuid.uuid4(),
        parent_id=parent.id,
        name="Test Child",
        age=8,
        birthday="2016-01-15",
        pin_hash=hash_password("1234"),
        fcm_token="test-fcm-token",
    )
    db.add(child)
    await db.commit()
    await db.refresh(child)
    return child


@pytest_asyncio.fixture
async def reason(db: AsyncSession, parent: Parent) -> Reason:
    reason = Reason(
        id=uuid.uuid4(),
        parent_id=parent.id,
        label="chores",
    )
    db.add(reason)
    await db.commit()
    await db.refresh(reason)
    return reason


@pytest_asyncio.fixture
async def parent_token(client: AsyncClient, parent: Parent) -> str:
    response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "parent@test.com",
            "password": "password123",
        },
    )
    return response.json()["access_token"]


@pytest_asyncio.fixture
async def child_token(client: AsyncClient, child: Child) -> str:
    response = await client.post(
        "/api/v1/child/login",
        json={
            "child_id": str(child.id),
            "pin": "1234",
        },
    )
    return response.json()["access_token"]

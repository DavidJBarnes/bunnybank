import uuid
from datetime import datetime, date
from decimal import Decimal

from sqlalchemy import String, Integer, Date, Numeric, DateTime, ForeignKey, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Child(Base):
    __tablename__ = "children"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    parent_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("parents.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    age: Mapped[int] = mapped_column(Integer, nullable=False)
    birthday: Mapped[date] = mapped_column(Date, nullable=False)
    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    pin_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    fcm_token: Mapped[str | None] = mapped_column(String(512), nullable=True)
    balance: Mapped[Decimal] = mapped_column(
        Numeric(12, 2), default=Decimal("0.00"), server_default="0.00"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    parent = relationship("Parent", back_populates="children")
    transactions = relationship(
        "Transaction", back_populates="child", cascade="all, delete-orphan"
    )

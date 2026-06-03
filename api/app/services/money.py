import uuid
import logging
from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.child import Child
from app.models.reason import Reason
from app.models.transaction import Transaction
from app.services.fcm import send_money_received_notification

logger = logging.getLogger("bunnybank.money")


async def send_money(
    db: AsyncSession,
    parent_id: uuid.UUID,
    child_ids: list[uuid.UUID],
    amount: float,
    reason_id: uuid.UUID,
):
    reason_result = await db.execute(
        select(Reason).where(Reason.id == reason_id, Reason.parent_id == parent_id)
    )
    reason = reason_result.scalar_one_or_none()
    if not reason:
        raise ValueError("Reason not found or does not belong to parent")

    children_result = await db.execute(
        select(Child).where(Child.id.in_(child_ids), Child.parent_id == parent_id)
    )
    children = children_result.scalars().all()
    if len(children) != len(child_ids):
        raise ValueError("One or more children not found or do not belong to parent")

    amount_decimal = Decimal(str(amount))
    transactions = []

    for child in children:
        child.balance += amount_decimal

        transaction = Transaction(
            child_id=child.id,
            reason_id=reason_id,
            amount=amount_decimal,
        )
        db.add(transaction)
        transactions.append((child, transaction))

    await db.commit()

    for child, _ in transactions:
        if child.fcm_token:
            try:
                await send_money_received_notification(
                    fcm_token=child.fcm_token,
                    amount=float(amount_decimal),
                    reason_label=reason.label,
                    new_balance=float(child.balance),
                )
            except Exception as e:
                logger.error("FCM notification failed for child %s: %s", child.id, e)

    return transactions

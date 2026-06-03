import logging

logger = logging.getLogger("bunnybank.fcm")


async def send_money_received_notification(
    fcm_token: str,
    amount: float,
    reason_label: str,
    new_balance: float,
):
    payload = {
        "type": "money_received",
        "amount": amount,
        "reason": reason_label,
        "new_balance": new_balance,
    }
    try:
        import firebase_admin
        from firebase_admin import credentials, messaging

        if not firebase_admin._apps:
            from app.config import settings

            if settings.firebase_credentials_file:
                cred = credentials.Certificate(settings.firebase_credentials_file)
                firebase_admin.initialize_app(cred)
            else:
                logger.warning(
                    "No Firebase credentials configured. FCM notifications disabled."
                )
                return

        message = messaging.Message(
            data={k: str(v) for k, v in payload.items()},
            token=fcm_token,
        )
        response = messaging.send(message)
        logger.info("FCM sent: %s", response)
    except Exception as e:
        logger.error("Failed to send FCM notification: %s", e)

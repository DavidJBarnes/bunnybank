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

        # Send a *notification* message (not data-only) with high-priority Android
        # config targeting the "cha_ching" channel, so the device shows it and
        # plays the cash-register sound even when the app is backgrounded or killed.
        message = messaging.Message(
            token=fcm_token,
            notification=messaging.Notification(
                title="Cha-ching! 🎉",
                body=f"You got ${amount:.2f} for {reason_label}!",
            ),
            data={k: str(v) for k, v in payload.items()},
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id="cha_ching",
                    sound="cha_ching",
                    priority="max",
                    default_sound=False,
                ),
            ),
        )
        response = messaging.send(message)
        logger.info("FCM sent: %s", response)
    except Exception as e:
        logger.error("Failed to send FCM notification: %s", e)

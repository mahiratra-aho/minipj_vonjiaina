from typing import Optional
import logging

_log = logging.getLogger("notifications")


def send_verification_code_email(email: str, code: str) -> bool:
    """Stub: send code by email. In production hook with SMTP or a provider."""
    _log.info(f"[stub] send code {code} to email {email}")
    return True


def send_verification_code_sms(phone: str, code: str) -> bool:
    _log.info(f"[stub] send code {code} to phone {phone}")
    return True

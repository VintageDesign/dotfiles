# `smslib`

A wrapper for KDE Connect to send SMS messages from your linux device.

---

Dependencies:

* [`kdeconnect`](http://www.omgubuntu.co.uk/2017/01/kde-connect-indicator-ubuntu)
* `indicator-kdeconnect` (recommended)

---

Example 1. This snippet will send you the message "This is a message" from your phone.

```python
from smslib import send_sms, read_contacts, get_ids

# Gets the known device IDs
print(get_ids())

# Lookup the phone number to avoid saving it in the repository
contacts = read_contacts('.contacts')
me = contacts['me']

# Send the SMS message from your device paired with KDE Connect
send_sms('This is a message', recipient=me, device='a9d2a0025c584e34')
```

Example 2. This script will send you an SMS message on the completion (or failure) of the decorated function call.

```python
#!/usr/bin/env python3
from smslib import alert_on_completion

@alert_on_completion(msg='task finished', recipient='me', device='a9d2a0025c584e34')
def long_running(a, b, c):
    """
        A function that takes forever to run. Maybe it trains a neural net to solve world hunger.
    """
    print('You should get an SMS notification')

if __name__ == '__main__':
    long_running(1, 2, 3)
```

---

A conveniency wrapper around `kdeconnect-cli` is provided by this [script](https://github.com/Notgnoshi/dotfiles/blob/master/bin/sms.py).

import argparse
import pathlib
import subprocess
import sys
import time
import inspect


def func_sig(f, *args, **kwargs):
    """
        Gets the function signature of the provided function and arguments. Good for using inside
        a decorator to get the call signature (and even better, call values) of wrapped functions.

        Requires the defined function to use *args and/or **kwargs, but no other arguments.

        Example
        >>> def func(*args, **kwargs):
        ...     sig = func_sig(func, *args, **kwargs)
        ...     print(sig)
        >>> func(a=1, b=2)
        func(a=1, b=2)
    """
    # Get the argument names of of the function f, along with any keyword args
    arg_names = inspect.getargspec(f)[0] + list(kwargs.keys())
    # Create a dict from tuples of (arg, value) pairs, first using *args, then **kwargs
    args_dict = dict(list(zip(arg_names, args)) + list(kwargs.items()))
    # Pretty format arguments, separated by a comma
    return f'{f.__name__}({", ".join(f"{a}={v}" for a, v in args_dict.items())})'


def send_sms(msg, recipient, device):
    """
        Sends the given `msg` to the provided `recipient`. `recipient` should be a valid
        phone number. `device` is the paired KDE Connect device ID.
    """
    output = subprocess.run(["kdeconnect-cli",
                             "--send-sms",
                             f"{msg}",
                             "--destination",
                             f"{recipient}",
                             "--device",
                             f"{device}"
                            ],
                            stdout=subprocess.PIPE)

    return output.stdout, output.stderr


def read_contacts(filename):
    """
        Read in contacts from the given file. Contacts should be saved in

            contact: phonenumber

        syntax, one per line.
    """
    contacts = {}
    with open(filename, 'r') as f:
        for line in f:
            key, value = line.strip().split(':')
            contacts[key.lower()] = value.lower()

    return contacts


def get_ids():
    """
        Lists device IDs known to KDE Connect.
    """
    output = subprocess.run(["kdeconnect-cli",
                             "--list-devices",
                            ],
                            stdout=subprocess.PIPE)
    return output.stdout, output.stderr


def alert_on_completion(msg=None, recipient='me', device='a9d2a0025c584e34'):
    """
        A decorator factory that sends an SMS alert on function completion. If the message is not
        provided, one will be generated. If the recipient phone number is not given, one will be
        looked up in ~/.contacts under the 'me' entry.

        The custom message to send will be replaced by an error message if an exception is raised.

        Examples:

        >>> alert = 'World domination model training completed.'
        >>> @alert_on_completion(alert)
        ... def world_domination_nn():
        ...     pass
        >>> @alert_on_completion()  # Is a factory, so must be called even w/o custom message.
        ... def solve_world_hunger():
        ...     raise NotImplementedError("We'll get there someday, just not today")
    """
    contacts = read_contacts(f'{str(pathlib.Path.home())}/.contacts')
    if recipient in contacts:
        recipient = contacts[recipient]

    # alert_on_completion is a decorator factory, and returns the following decorator.
    def __alert_decorator(f, msg=msg, recipient=recipient):
        """
            Returns a decorator that sends an SMS message to the given recipient with an optional
            message.
        """
        def __alert_on_completion(*args, **kwargs):
            """
                A decorator that times a function call and sends a helpful SMS message
                on completion or failure.
            """
            # Get the function signature with argument values.
            sig = func_sig(f, *args, **kwargs)

            try:
                # Attempt to call the function, timing its execution.
                start_time = time.time()
                result = f(*args, **kwargs)
                end_time = time.time()

                # Provide a default message if one is not provided
                if msg is None:
                    time_elapsed = end_time - start_time
                    message = f'{sig} complete. Elapsed time {time_elapsed:.4f} seconds.'
                else:
                    message = msg

                stdout, stderr = send_sms(message, recipient, device)
                return result

            except Exception as exc:
                # Get the exception type. It's also possible to get the traceback.
                exc_type = sys.exc_info()[0].__name__
                message = f'{sig} failed with exception "{exc_type}: {exc}".'
                # Overwrite the requested message with the one detailing the exception.
                stdout, stderr = send_sms(message, recipient, device)

                # If a decorated function raises an exception, we shouldn't suppress that.
                raise exc

        return __alert_on_completion
    return __alert_decorator

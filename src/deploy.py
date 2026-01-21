#!/usr/bin/env python3
"""
Simple hello world module.
"""


def hello_world(name: str = "World") -> str:
    """
    Return a hello message.

    Args:
        name: Name to greet

    Returns:
        Greeting message
    """
    return f"Hello, {name}!"


if __name__ == "__main__":
    print(hello_world())

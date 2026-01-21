#!/usr/bin/env python3
"""
Unit tests for hello world module.
"""

import sys
import unittest
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

try:
    from deploy import hello_world
except ImportError:
    # If deploy module not found, check the actual module name in src/
    from pathlib import Path

    src_path = Path(__file__).parent.parent / "src"
    print(f"Looking for modules in: {src_path}")
    if src_path.exists():
        print(f"Available files: {list(src_path.glob('*.py'))}")
    raise


class TestHelloWorld(unittest.TestCase):
    """Unit tests for hello_world function."""

    def test_hello_world_default(self):
        """Test hello_world with default argument."""
        result = hello_world()
        self.assertEqual(result, "Hello, World!")

    def test_hello_world_custom_name(self):
        """Test hello_world with custom name."""
        result = hello_world("Alice")
        self.assertEqual(result, "Hello, Alice!")

    def test_hello_world_empty_string(self):
        """Test hello_world with empty string."""
        result = hello_world("")
        self.assertEqual(result, "Hello, !")

    def test_hello_world_return_type(self):
        """Test that hello_world returns a string."""
        result = hello_world()
        self.assertIsInstance(result, str)


if __name__ == "__main__":
    unittest.main()

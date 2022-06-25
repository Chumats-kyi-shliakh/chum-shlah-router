"""
Create db model
"""

from yoyo import step

__depends__ = {}

steps = [
    step("CREATE EXTENSION IF NOT EXISTS postgis;"),
    step("CREATE EXTENSION IF NOT EXISTS pgrouting;")
]

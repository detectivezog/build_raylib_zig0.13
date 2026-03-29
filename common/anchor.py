import os

def get_root():
    current = os.path.dirname(os.path.abspath(__file__))
    while current != os.path.dirname(current):
        if os.path.exists(os.path.join(current, ".pebble")):
            return current
        current = os.path.dirname(current)
    cwd = os.getcwd()
    if os.path.exists(os.path.join(cwd, ".pebble")):
        return cwd
    raise FileNotFoundError("Could not find .pebble root anchor.")

ROOT = get_root()
MODULES = os.path.join(ROOT, "modules")
LIBS = os.path.join(ROOT, "libs")

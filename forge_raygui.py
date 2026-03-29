import os
import urllib.request

# Put it directly into our Sovereign Vault
TARGET_DIR = os.path.join(os.getcwd(), "modules", "raylib", "include")
RAYGUI_URL = "https://raw.githubusercontent.com/raysan5/raygui/master/src/raygui.h"

def fetch_raygui():
    if not os.path.exists(TARGET_DIR):
        print("[!] Error: modules/raylib/include not found. Run forge_raylib.py first.")
        return

    dest = os.path.join(TARGET_DIR, "raygui.h")
    print(f"--- Forging Raygui ---")
    print(f"Downloading raygui.h...")
    
    req = urllib.request.Request(RAYGUI_URL, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response, open(dest, 'wb') as out_file:
        out_file.write(response.read())
        
    print(f"[SUCCESS] raygui.h secured in {TARGET_DIR}")

if __name__ == "__main__":
    fetch_raygui()

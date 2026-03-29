import os
import shutil
import urllib.request
import zipfile
import tarfile
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), 'common'))
from anchor import ROOT, MODULES

# --- Configuration ---
RAYLIB_VERSION = "5.0"
ZIG_WRAPPER_COMMIT = "cd71c85d571027ac8033357f83b124ee051825b3"

SOURCES = {
    "win": f"https://github.com/raysan5/raylib/releases/download/{RAYLIB_VERSION}/raylib-{RAYLIB_VERSION}_win64_mingw-w64.zip",
    "lin": f"https://github.com/raysan5/raylib/releases/download/{RAYLIB_VERSION}/raylib-{RAYLIB_VERSION}_linux_amd64.tar.gz",
    "mac": f"https://github.com/raysan5/raylib/releases/download/{RAYLIB_VERSION}/raylib-{RAYLIB_VERSION}_macos.tar.gz",
    "zig_wrapper": f"https://github.com/raylib-zig/raylib-zig/archive/{ZIG_WRAPPER_COMMIT}.zip"
}

# The final pristine module destination
TARGET_MOD = os.path.join(MODULES, "raylib")
TEMP_DIR = os.path.join(ROOT, "temp_forge")

def download_and_extract(url, extract_to, is_tar=False):
    file_path = os.path.join(TEMP_DIR, "dl_file")
    print(f"  -> Downloading {url.split('/')[-1]}...")
    
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response, open(file_path, 'wb') as out_file:
        out_file.write(response.read())

    print(f"  -> Extracting...")
    if is_tar:
        with tarfile.open(file_path, "r:gz") as tar:
            tar.extractall(extract_to)
    else:
        with zipfile.ZipFile(file_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
            
    os.remove(file_path)
    # Return the name of the root folder inside the archive
    return os.path.join(extract_to, os.listdir(extract_to)[0])

def build_vault():
    print(f"=== Ziguezon Forge: Cross-Platform Raylib Module ===")
    
    if os.path.exists(TARGET_MOD):
        print(f"[!] {TARGET_MOD} already exists. Cleaning...")
        shutil.rmtree(TARGET_MOD)
        
    os.makedirs(TEMP_DIR, exist_ok=True)
    
    # Setup final directories
    os.makedirs(os.path.join(TARGET_MOD, "src"), exist_ok=True)
    os.makedirs(os.path.join(TARGET_MOD, "include"), exist_ok=True)
    for os_name in ["win", "lin", "mac"]:
        os.makedirs(os.path.join(TARGET_MOD, "lib", os_name), exist_ok=True)

    try:
        # 1. Process Windows Binaries (Also grabs the C headers)
        print("\n[1/4] Processing Windows (MinGW) Binaries...")
        win_dir = download_and_extract(SOURCES["win"], os.path.join(TEMP_DIR, "win"))
        shutil.copy2(os.path.join(win_dir, "lib", "libraylib.a"), os.path.join(TARGET_MOD, "lib", "win", "libraylib.a"))
        
        # Copy headers from the Windows package (they are universal C headers)
        for h_file in["raylib.h", "raymath.h", "rlgl.h"]:
            shutil.copy2(os.path.join(win_dir, "include", h_file), os.path.join(TARGET_MOD, "include", h_file))

        # 2. Process Linux Binaries
        print("\n[2/4] Processing Linux Binaries...")
        lin_dir = download_and_extract(SOURCES["lin"], os.path.join(TEMP_DIR, "lin"), is_tar=True)
        shutil.copy2(os.path.join(lin_dir, "lib", "libraylib.a"), os.path.join(TARGET_MOD, "lib", "lin", "libraylib.a"))

        # 3. Process macOS Binaries
        print("\n[3/4] Processing macOS Binaries...")
        mac_dir = download_and_extract(SOURCES["mac"], os.path.join(TEMP_DIR, "mac"), is_tar=True)
        shutil.copy2(os.path.join(mac_dir, "lib", "libraylib.a"), os.path.join(TARGET_MOD, "lib", "mac", "libraylib.a"))

        # 4. Process Zig Wrapper
        print("\n[4/4] Processing Zig Wrapper Source...")
        zig_dir = download_and_extract(SOURCES["zig_wrapper"], os.path.join(TEMP_DIR, "zig"))
        
        # The wrapper logic is inside the 'lib' folder of the repo. Copy all .zig files.
        source_lib_dir = os.path.join(zig_dir, "lib")
        for item in os.listdir(source_lib_dir):
            if item.endswith(".zig"):
                shutil.copy2(os.path.join(source_lib_dir, item), os.path.join(TARGET_MOD, "src", item))

        print(f"\n[SUCCESS] Universal Raylib Module forged at: {TARGET_MOD}")
        
    finally:
        if os.path.exists(TEMP_DIR):
            shutil.rmtree(TEMP_DIR)

if __name__ == "__main__":
    build_vault()

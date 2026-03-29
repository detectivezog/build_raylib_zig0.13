import os
import sys
import shutil
import configparser
import urllib.request
import zipfile
import subprocess

ZIG_VERSION = "0.13.0"
RAYLIB_BIN_URL = "https://github.com/raysan5/raylib/releases/download/5.0/raylib-5.0_win64_mingw-w64.zip"
RAYGUI_URL = "https://raw.githubusercontent.com/raysan5/raygui/master/src/raygui.h"

def setup_env():
    print("--- [1/3] Setting up Environment ---")
    if not os.path.exists('paths.ini'):
        config = configparser.ConfigParser()
        config['paths'] = {
            'zig_path': 'C:/Users/WatermelonOwl/zig/013',
            'mingw_path': 'C:/.dev/polyglot/w64devkit/x86_64-w64-mingw32'
        }
        with open('paths.ini', 'w') as f: config.write(f)

    for f in["modules/raylib/include", "modules/raylib/lib/win", "src/ui", "zig-out"]: 
        os.makedirs(f, exist_ok=True)

def forge_binaries():
    print("--- [2/3] Forging Raylib Vault ---")
    inc_dir = "modules/raylib/include"
    lib_dir = "modules/raylib/lib/win"
    
    if not os.path.exists(os.path.join(lib_dir, "libraylib.a")):
        urllib.request.urlretrieve(RAYLIB_BIN_URL, "temp_raylib.zip")
        with zipfile.ZipFile("temp_raylib.zip", 'r') as z: z.extractall("temp_bin")
        base = os.path.join("temp_bin", os.listdir("temp_bin")[0])
        shutil.copy2(os.path.join(base, "lib/libraylib.a"), lib_dir)
        shutil.copy2(os.path.join(base, "include/raylib.h"), inc_dir)
        shutil.copy2(os.path.join(base, "include/raymath.h"), inc_dir)
        shutil.rmtree("temp_bin")
        os.remove("temp_raylib.zip")

    if not os.path.exists(os.path.join(inc_dir, "raygui.h")):
        urllib.request.urlretrieve(RAYGUI_URL, os.path.join(inc_dir, "raygui.h"))

def build_exe():
    print("--- [3/3] Compiling Windows Viewport ---")
    config = configparser.ConfigParser()
    config.read('paths.ini')
    zig_exe = os.path.join(config['paths']['zig_path'], "zig.exe")
    
    root = os.getcwd()
    main_zig = os.path.abspath("src/main.zig").replace("\\", "/")
    c_impl = os.path.abspath("src/raygui_impl.c").replace("\\", "/")
    inc_path = os.path.abspath("modules/raylib/include").replace("\\", "/")
    lib_path = os.path.abspath("modules/raylib/lib/win/libraylib.a").replace("\\", "/")
    out_exe = os.path.abspath("viewport.exe").replace("\\", "/")

    # THE FIX: No -M or --mod flags. Pure compilation.
    cmd =[
        zig_exe, "build-exe", main_zig, c_impl,
        "-lc", lib_path,
        "-lgdi32", "-lwinmm", "-luser32", "-lshell32", "-lopengl32",
        f"-I{inc_path}",
        "-target", "x86_64-windows-gnu",
        f"-femit-bin={out_exe}"
    ]
    
    subprocess.run(cmd)
    if os.path.exists(out_exe):
        print(f"\n[VICTORY] Executable created at: {out_exe}")
    else:
        print("\n[FAILURE] Compilation failed.")

if __name__ == "__main__":
    setup_env()
    forge_binaries()
    build_exe()

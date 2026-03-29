#include <stdlib.h> // Required for atof

// POLYFILL: Raylib 5.0 removed this, but Raygui still wants it.
float TextToFloat(const char *text) {
    return (float)atof(text);
}

#define RAYGUI_IMPLEMENTATION
#include "raylib.h"
#include "raygui.h"

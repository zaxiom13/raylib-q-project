#include "csrc/raylib_q_types.h"

#include <limits.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define RAYLIB_Q_RUNTIME_VERSION "2026.02.11"

static Runtime g_rt = {0};

#include "csrc/runtime/runtime_helpers.inc"
#include "csrc/runtime/runtime_command_q.inc"
#include "csrc/runtime/runtime_command_text.inc"
#include "csrc/runtime/runtime_runtime_and_api.inc"

module rcamera;

/*******************************************************************************************
*
*   rcamera - Basic camera system with support for multiple camera modes
*
*   CONFIGURATION:
*       #define RCAMERA_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RCAMERA_STANDALONE
*           If defined, the library can be used as standalone as a camera system but some
*           functions must be redefined to manage inputs accordingly.
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, update and maintenance
*       Christoph Wagner:   Complete redesign, using raymath (2022)
*       Marc Palau:         Initial implementation (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2022-2024 Christoph Wagner (@Crydsch) & Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/

import raymath : Matrix;
import raylib;
import rlgl;


extern (C) @nogc nothrow:

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
enum CAMERA_CULL_DISTANCE_NEAR = RL_CULL_DISTANCE_NEAR;
enum CAMERA_CULL_DISTANCE_FAR = RL_CULL_DISTANCE_FAR;

//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Below types are required for standalone usage
//----------------------------------------------------------------------------------

// Vector2, 2 components

// Vector x component
// Vector y component

// Vector3, 3 components

// Vector x component
// Vector y component
// Vector z component

// Matrix, 4x4 components, column major, OpenGL style, right-handed

// Matrix first row (4 components)
// Matrix second row (4 components)
// Matrix third row (4 components)
// Matrix fourth row (4 components)

// Camera type, defines a camera position/orientation in 3d space

// Camera position
// Camera target it looks-at
// Camera up vector (rotation over its axis)
// Camera field-of-view apperture in Y (degrees) in perspective, used as near plane width in orthographic
// Camera projection type: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC

// Camera type fallback, defaults to Camera3D

// Camera projection

// Perspective projection
// Orthographic projection

// Camera system modes

// Camera custom, controlled by user (UpdateCamera() does nothing)
// Camera free mode
// Camera orbital, around target, zoom supported
// Camera first person
// Camera third person

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------

// Prevents name mangling of functions

Vector3 GetCameraForward (Camera* camera);
Vector3 GetCameraUp (Camera* camera);
Vector3 GetCameraRight (Camera* camera);

// Camera movement
void CameraMoveForward (Camera* camera, float distance, bool moveInWorldPlane);
void CameraMoveUp (Camera* camera, float distance);
void CameraMoveRight (Camera* camera, float distance, bool moveInWorldPlane);
void CameraMoveToTarget (Camera* camera, float delta);

// Camera rotation
void CameraYaw (Camera* camera, float angle, bool rotateAroundTarget);
void CameraPitch (Camera* camera, float angle, bool lockView, bool rotateAroundTarget, bool rotateUp);
void CameraRoll (Camera* camera, float angle);

Matrix GetCameraViewMatrix (Camera* camera);
Matrix GetCameraProjectionMatrix (Camera* camera, float aspect);

// RCAMERA_H
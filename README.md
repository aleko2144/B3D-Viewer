# B3D-Viewer
Virtual World Inventor games (Hard Truck, King of The Road) *.b3d viewer powered by Godot 4.3 engine.

A utility for viewing B3D files built on the Godot 4.3 engine. It supports both early SoftLab-NSK projects (MirDemo, etc.) and the game "Hard Truck 2".
The project is based on the work of, among others, [Duude92](https://github.com/Duude92), [AlexKimov](https://github.com/AlexKimov), [Voron295](https://github.com/Voron295) and [LabVaKars](https://github.com/LabVaKars).

The project was written primarily in 2023. The code is rough and clunky, but generally functional. If anyone decides to improve it, good luck!

[The v2.0 branch](https://github.com/aleko2144/B3D-Viewer/tree/v2.0) contains another version of the project, written from scratch in 2025 and compatible only with VWI games released before "Hard Truck 2", although the code quality is much better.

[Описание на русском языке доступно здесь](README-RU.md)

## Launching the compiled application:
1. Unzip the application to a folder on the same partition as the .b3d files.
2. In viewer.ini, set VWIVersion = 2 if you plan to view the "Hard Truck 2" game files. Otherwise, set VWIVersion = 1.
3. In viewer.ini, set scenes_file = "<b3d_list>.lst". Sample lists are included with the program (files scenes_d1.lst and scenes_d2.lst).
4. If you plan to view the "Hard Truck 2" .b3d files, you should first load the common.b3d file, and then load the rest of the files.

Important! It's highly recommended not to open large files like trucks.b3d in their entirety! It's better to export the necessary data from the large file into a separate .b3d file using [B3D Block Editor](https://github.com/Duude92/B3DBlockEditor) and import that instead of the large file. Otherwise, importing will take a very long time, and the application will become extremely slow (or even stop working altogether).
Also, the path to the .b3d files must be relative to the location of viewer.exe.

### lst-file parameters:
Loading a single file: "scene: (path) (hide)", where (path) is the path to the file, (hide) hides the scene after import (only for common.b3d in the game "Hard Truck 2").

Examples: "scene: ./COMMON/COMMON.B3D : hide", "scene: ./MENV/dr.b3d"

Loading all b3d files from a specified directory: "dir: (path)", where (path) is the path to the b3d files.

Example: "dir: ./ENV/"

## Controls:
### Miscellaneous:
1) F1 - hide/show GUI
2) F2 - open menu for viewing scene object list
3) F3 - open menu for interacting with switchable objects
4) F4 - open menu for switching object display
5) F6 - screenshot
6) F10 - "About" menu
7) Ctrl+X - open menu for selecting folder for saving all imported scenes in gltf format

### Toggle rendering modes:
1) 1 - wireframe / normal (grid mode)
2) 2 - unshaded / normal (equilateral lighting)

### Toggle background:
1) 3 - texture or preset color (if available) / gray color / sky

### Toggle lighting:
1) 4 - background light on/off
2) L - flashlight on/off

### Movement:
1) W/S - forward / backward
2) D/A - right / left
3) E/Q - up / down
4) Right mouse button + mouse movement - look
5) Mouse wheel up - increase movement speed
6) Mouse wheel down - decrease movement speed
7) R - reset position

# ray-d
------
Raylib](https://www.raylib.com/index.html) bindings for Dlang!
New Dlang binding for the latest new version of Raylib. This
binding also includes `raygui`.
## Usage
Before using it, you must make sure you have Raylib installed on your system. You can install it from its [official website](https://www.raylib.com/index.html), install it with your package manager (Linux) or build it from the [source code](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux).
Once you have verified that Raylib is installed, as it is not currently part of [dub](https://code.dlang.org/), you can build it and bring the directory into your project by adding this line to your ``dub.json`:
```json
"dependencies": {
    "ray-d": { "path": "../"}
}
```
## Construction (UNIX/Linux/Mac)
-------
In your terminal, run this command to build it.
```bash
dub build
```
## Build (Windows)
-------
* Coming soon, I don't have a Windows computer right now :( *
## Example
You can see the [demo](demo/) directory which demonstrates a basic application made
with ray-d.

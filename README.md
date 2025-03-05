# pthreads-not-reused

## Description
This is a fairly minimal example to reproduce an issue involving a pthread-enabled Emscripten build not reusing detached pthreads.
There are two buttons added to the Emscripten-generated HTML, "Exec 1 pthread" & "Exec 8 pthreads".  The project builds specifying
a pool of 4 pthreads at startup.  You can hit the "Exec 1 pthread" button all day with no issue.  However, hitting the Exec 8 pthreads"
button causes it to complain of an exhausted thread pool and it spins up 4 additional pthreads.

When this issue is addressed, whether it's an issue in the emsdk or just lack of understanding, this will be updated with that info.

## Installation
This project comes with a basic makefile for compiling the C++ to WASM.  Typing `make help` will give a usage message.

You can set up to build in one of several ways.  One easy way is to use a [Docker image](https://hub.docker.com/r/emscripten/emsdk/tags).  The emsdk version must be at least 3.1.64.
Once you have an emsdk set up to build:
`emmake make`
Then to set up the project to run:
`npm install`

## Usage
### Testing
Just run:
`node express.mjs`
Bring up your browser to localhost:8088/
It will redirect to bin_pt/dbg/my.html.

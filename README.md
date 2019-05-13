# mruby_ev3_application

This is very early work in progress and will eventually become an application template for [MRuby](https://mruby.org)
apps running on [LEGO's EV3](https://education.lego.com/en-gb/product/mindstorms-ev3) brick.

The code relies heavily on [ev3dev](https://www.ev3dev.org/), a Debian based Linux distribution which runs on EV3
bricks. Ev3dev supports some more microcomputers for robots, but the code in this project is currently not meant to run
on them — it is EV3 only.

## Installation

### Prerequisites

For cross-platform compilation, this project relies on ev3dev's Docker image, so you'll have to install Docker first.
Make sure to enable foreign binary support on the host. There is a
[detailed instructions page on ev3dev.org](https://www.ev3dev.org/docs/tutorials/using-docker-to-cross-compile/).

You will also have to [install ev3dev on your EV3](https://www.ev3dev.org/docs/getting-started/). Don't worry, it is
not installed permanently on your EV3, but on a Micro SD card. As soon as you remove that card, the official LEGO
firmware will be loaded.

### Clone The Repository

Please note that the MRuby source is included as git submodule; to init this submodule, the `--recurse-submodules`
option should be passed to the `clone` command.

    $> git clone --recurse-submodules https://github.com/tosch/mruby_ev3_application

    $> cd mruby_ev3_application

### Build MRuby

Before you can compile any application, you have to compile libmruby and the MRuby binaries. There is a shell script
which executes the required docker-compose command:

    $> bin/compile-mruby

### Compile (the Sample) Applications

Application binaries are created in multiple steps:
1. Build a `.c` file that contains bytecode from the application's Ruby source.
2. Build another `.c` file that contains an application loader that loads the bytecode and executes it.
3. Compile the application (loader) into a statically linked binary.

There are Rake tasks defined in the `/app` folder to help with those compilation steps:

    $> bin/compile-all

will execute `rake all` in the cross-compilation Docker container. This compiles all the applications in `/app/mrblib`.
It will create two different binaries for each app: `bin/NAME.app` and `bin/NAME-debug.app`. The `-debug` variant
contains debugging information, ie. it will print a backtrace on exceptions.

### Copy the Binaries to the EV3 Brick

If there is a [network connection to the EV3 brick](https://www.ev3dev.org/docs/networking/), you can use `scp` to copy
the application binaries to your robot:

    $> scp app/bin/* robot@ev3dev.local:bin

You can launch the apps either via a
[SSH console](https://www.ev3dev.org/docs/tutorials/connecting-to-ev3dev-with-ssh/) or via BrickMan on the device
itself.

### Copy mirb to the EV3 Brick

mirb is a MRuby REPL. It is included in the MRuby build. If you want to have a Ruby console on your EV3, you can copy
the binary:

    $> scp mruby/build/ev3/bin/mirb robot@ev3dev.local:bin

(You can also copy the `mruby` binary if you want to directly execute Ruby files on your EV3.)

## Directory Structure

* `/app`: This is where the applications are:
  - `/app/mrblib` contains the Ruby files (one per app)
  - `/app/src` contains auto-generated C source files for the applications and a skeleton file for an application
    loader
  - `/app/bin` contains the compiled binaries. `-debug` files have debug information included in the Ruby bytecode,
    `-host` files are NOT cross-compiled; they can be executed on the compiling host (although that probably doesn't
    make much sense as required EV3Dev system files are not present on the host).

  This is mounted in `/opt/app` in the cross-compilation Docker container.
* `/bin`: This contains helper scripts for some common tasks
* `/docker`: This contains the `Dockerfile` for the cross-compilation environment and a `docker-compose.yml`.
* `/mruby`: This is a git submodule of the mruby source code.

  This is mounted in `/opt/mruby` in the cross-compilation Docker container.
* `/mruby-ev3`: This is a mrbgem with lots of library code for using EV3Dev in MRuby applications.

  This is mounted in `/opt/mruby-ev3` in the cross-compilation Docker container.

## Develop Your Own Application

Sorry, this section is still to be written. Maybe have a look at the example applications in the `app/mrblib` folder.

## TODO

* [ ] Document the `EV3` module and its classes
* [ ] Increase test coverage
* [ ] Document how to test mruby-ev3 applications
* [ ] Move mrbgem into its own repository
* [ ] Support the EV3 display (monochrome Linux framebuffer device)
* [ ] Allow keypress event handling using [concurrently](https://github.com/christopheraue/m-ruby-concurrently)
* [ ] Build a shared `libmruby.so` so that the application binaries get smaller
* [ ] Try using mruby/c

## Author(s)

* [Torsten Schönebaum](https://github.com/tosch)

## Legal Disclaimer

LEGO and Mindstorms are trademarks of the LEGO Group.

This project is by no means associated to LEGO; it is no official software for the EV3 and you use it at your own risk.
See [the LICENSE file](./LICENSE).

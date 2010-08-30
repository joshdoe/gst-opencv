gst-opencv
==========

gst-opencv is a plugin for the [GStreamer][] framework, consisting of both
elements mapped directly to [OpenCV][] functions as well as composite
elements using a combination of functions.

Requirements
------------
* gstreamer and gst-plugins-base (>=0.10.29)
* OpenCV (>=2.0?)
* autoconf (>=2.52), automake (>=1.7), libtool (>=1.5.0), and pkg-config (>=0.11.0)
* **OR** CMake (>=2.8?)

Build It
--------
There are two ways to build gst-opencv, the traditional make system and
[CMake][].

### make ###
Read `INSTALL` for more information, but in short:

    ./autogen.sh --prefix=/gstreamer/plugins/dir
    make
    make install

### CMake ###
CMake can be used to generate build files for a number of different build
systems, including make and Visual Studio. It is recommended to perform an
out-of-place by creating a subdirectory for the build files. To see a list
of the available build generators simply run `cmake`. The following are just
two of the many combinations of platforms and build systems that can be used.

#### Windows ####
You'll need to specify the location of required libraries by setting some
environment variables:

    set GSTREAMER_DIR=C:\gstreamer
    set LIBXML2_DIR=%GSTREAMER_DIR%
    set LIBICONV_DIR=%GSTREAMER_DIR%
    set GLIB2_DIR=%GSTREAMER_DIR%
    set OPENCV_DIR=C:\opencv

To generate a Visual Studio 2008 solution file and install the resulting
plugins in `C:\gstreamer\plugins` run the following commands:

    mkdir build
    cd build
    cmake .. -G "Visual Studio 9 2008" -DCMAKE_INSTALL_PREFIX=C:\gstreamer\plugins

Alternatively, you can use the CMake gui, `cmake-gui`.

Once the build files have been generated, open the solution file and either
"Build Solution" or build the `ALL_BUILD` project. To install the plugin, issue
a build command on the `INSTALL` project.

#### Linux ####
To generate makefiles, build, then install, run the following commands:

    mkdir build
    cd build
    cmake .. -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/gstreamer/plugin/dir
    make
    make install

Contributing
------------
Fork it!

[gstreamer]: http://www.gstreamer.net/ "GStreamer homepage"
[opencv]: http://opencv.willowgarage.com/wiki/ "OpenCV homepage"
[cmake]: http://www.cmake.org/ "CMake homepage"

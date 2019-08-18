#!/usr/bin/env julia --project=@.

using PackageCompiler

# Or if you simply want to get a native system image e.g. when you have downloaded the generic Julia install:
force_native_image!()

# Build an executable
build_executable(
    "src/run.jl", # Julia script containing a `julia_main` function, e.g. like `examples/hello.jl`
    snoopfile = "test/runtests.jl", # Julia script which calls functions that you want to make sure to have precompiled [optional]
    builddir = "build" # that's where the compiled artifacts will end up [optional]
)

# Build a shared library
build_shared_lib("src/run.jl")

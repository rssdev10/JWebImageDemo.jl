#!/usr/bin/env julia --project=@.

const sysimage_dir = "sysimage"
isdir(sysimage_dir) || mkdir(sysimage_dir)

import Pkg;
Pkg.add("PackageCompiler")
project_name = Pkg.project().name |> Symbol


import PackageCompiler
PackageCompiler.create_sysimage(
    project_name,
    sysimage_path = joinpath(sysimage_dir, "image.so"),
    # precompile_statements_file=joinpath(sysimage_dir, "precompile.jl"),
    precompile_execution_file = "test/runtests.jl",
)

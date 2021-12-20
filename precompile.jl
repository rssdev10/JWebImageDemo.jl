#!/usr/bin/env julia --project=@. --startup-file=no

const sysimage_dir = "sysimage"
isdir(sysimage_dir) || mkdir(sysimage_dir)

import Pkg;
Pkg.add("PackageCompiler")
project_name = Pkg.project().name |> Symbol


import PackageCompiler
PackageCompiler.create_sysimage(
    project_name,
    cpu_target="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)",
    sysimage_path = joinpath(sysimage_dir, "image.so"),
    # precompile_statements_file=joinpath(sysimage_dir, "precompile_trace.jl"),
    precompile_execution_file = "test/runtests.jl",
)

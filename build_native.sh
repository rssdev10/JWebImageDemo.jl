#!/bin/sh

PACKAGE_PATH=`julia -e 'using PackageCompiler; PackageCompiler |> pathof |> dirname |> println'`

julia --project=@. "$PACKAGE_PATH/../juliac.jl" -vae run.jl

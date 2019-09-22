#!/usr/bin/env julia --project=@.
module Starter

# this part is required for PackageCompiler
import Sockets
Sockets.__init__()

import HTTP.URIs
import HTTP.Parsers
URIs.__init__()
Parsers.__init__()

import QuartzImageIO
#import ImageMagick
# end of PackageCompiler

include("src/server.jl")

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    start_server()
    return 0
end

include("src/server.jl")

# run when exactly this script is activated
endswith(PROGRAM_FILE,  basename(@__FILE__)) && start_server()
end

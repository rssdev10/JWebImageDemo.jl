#!/usr/bin/env julia --project=@.

# this part is required for PackageCompiler
import Sockets
Sockets.__init__()

import HTTP.URIs
import HTTP.Parsers
URIs.__init__()
Parsers.__init__()
# end of PackageCompiler

include("src/server.jl")

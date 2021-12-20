#!/usr/bin/env julia --project=@.
# module Starter
doc = """Web service starter

Usage:
  $(Base.basename(@__FILE__)) [--port=<num>] [--base_url=<url>] [--bind=<ip>]

Options:
  -h --help         Show this screen
  -p, --port=<num>  Port  [default: 8080]
  -b, --bind=<ip>   Bind address [default: 0.0.0.0]
  --base_url=<url>  Additional URL prefix for the service [default: /]

"""

using DocOpt  # import docopt function
using Pkg

args = docopt(doc, version=Pkg.project().version)
#@info args

using Sockets
BASE_URL = args["--base_url"]
HOST = Sockets.getaddrinfo(args["--bind"])
PORT = parse(Int, args["--port"])

app_server = Pkg.project().name
@info "Activating web service..."
@eval using $(Symbol(app_server))
m = getfield(Main, Symbol(app_server))

# endswith(PROGRAM_FILE, basename(@__FILE__)) && start_server()
m.AppServer.start_server(
    host = string(HOST),
    port = PORT,
    base_url = BASE_URL,
)
# end
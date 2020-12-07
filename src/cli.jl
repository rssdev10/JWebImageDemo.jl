
# Base.basename(@__FILE__)

doc = """Web service starter

Usage:
  $(PROGRAM_FILE) [--port=<num>] [--base_url] [--bind=<ip>]

Options:
  -h --help         Show this screen
  -p, --port=<num>  Port  [default: 8080]
  -b, --bind=<ip>   Bind address [default: 127.0.0.1]
  --base_url        Additional URL prefix for the service

"""

using DocOpt  # import docopt function

args = docopt(doc, version=v"1.0.0")
#@info args

using Sockets
BASE_URL = args["--base_url"] || ""
HOST = Sockets.getaddrinfo(args["--bind"])
PORT = parse(Int, args["--port"])

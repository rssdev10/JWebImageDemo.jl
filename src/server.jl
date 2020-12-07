#!/usr/bin/env julia --project=@.

# process command line
include("./cli.jl")

# main service code

using Bukdu # pipeline Conn routes resources get plug Router
using Sockets
using FileIO

using JWebImageDemo

function get_server()
    if haskey(ENV, "ON_HEROKU")
        (port = parse(Int, ENV["PORT"]), host = ip"0.0.0.0")
    else
        (port = PORT, host = HOST)
    end
end

server = get_server()

struct WelcomeController <: ApplicationController
    conn::Conn
end

import HTTP, HTTP.Parsers
# include business logic part
include("./handlers.jl")

# register handlers
routes() do
    plug(Plug.Static, at = "$BASE_URL/", from = normpath(@__DIR__, "..", "public"))

    post("$BASE_URL/api/process_image", WelcomeController, process_image)
end

function start_server()
    Bukdu.start(server.port; host = server.host)

    # Router.call(get, "/") #
    # CLI.routes()

    Base.JLOptions().isinteractive == 0 && wait()
    #Bukdu.stop()
end

endswith(PROGRAM_FILE, basename(@__FILE__)) && start_server()

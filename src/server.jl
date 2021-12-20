module AppServer

# main service code

using Bukdu # pipeline Conn routes resources get plug Router
using Sockets
using FileIO

using JWebImageDemo

function get_server(host, port)
    if haskey(ENV, "ON_HEROKU")
        (port = parse(Int, ENV["PORT"]), host = ip"0.0.0.0")
    else
        (port = port, host = host)
    end
end

struct WelcomeController <: ApplicationController
    conn::Conn
end

import HTTP, HTTP.Parsers
# include business logic part
include("./handlers.jl")

function register_routes()
    global BASE_URL
    # register handlers
    routes() do
        plug(Plug.Static, at = "$BASE_URL/", from = normpath(@__DIR__, "..", "public"))

        post(BASE_URL * "api/process_image", WelcomeController, process_image)
    end
end

function start_server(; host = "127.0.0.1", port = 8080, base_url = "")
    global BASE_URL = base_url * (endswith(base_url, "/") ? "" : "/")
    if isdefined(AppServer, :register_routes)
        register_routes()
    else
        @error "register_routes method must be defined"
        throw(UndefVarError)
    end

    local server = get_server(Sockets.getaddrinfo(host), port)
    Bukdu.start(server.port; host = server.host)

    # Router.call(get, "/") #
    CLI.routes()

    Base.JLOptions().isinteractive == 0 && wait()
    #Bukdu.stop()
end
# endswith(PROGRAM_FILE, basename(@__FILE__)) && start_server()
end
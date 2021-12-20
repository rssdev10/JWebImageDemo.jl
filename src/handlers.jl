"""
Get appropriate part of a body content by name

Returns found part or nothing

# Arguments
- `multipart::Vector{HTTP.Multipart}`: HTTP.jl provided vector of parts
- `name::String`: the name of part parameter
"""
get(multipart::Vector{HTTP.Multipart}, name::String) =
    findfirst(part -> part.name == name, multipart) |>
    idx -> isnothing(idx) ? nothing : multipart[idx]

"""
Process incomming query with image file
Generate output image in PNG format
"""
function process_image(c::WelcomeController)
    local multiparts = HTTP.parse_multipart_form(c.conn.request)

    # dump(multiparts)
    local mp_file = get(multiparts, "f_image")
    local mp_num = get(multiparts, "num")

    isnothing(mp_file) &&
        return render(Text, "Please upload some image file in f_image field")
    isnothing(mp_num) &&
        return render(Text, "Please specify number of sections in num field")

    local img = FileIO.load(Stream{format"PNG"}(mp_file.data))
    local out_img = JWebImageDemo.permute_image(
        img,
        tryparse(Int, String(take!(mp_num.data))) |> x -> something(x, 5),
    )
    local out_buf = IOBuffer()
    show(out_buf, MIME("image/png"), out_img)
    # return Render(mp_file.contenttype, identity, take!(out_buf))
    return Render("image/png", identity, take!(out_buf))
end

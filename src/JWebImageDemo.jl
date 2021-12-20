"""
The module implements logic of permutation of input image
"""
module JWebImageDemo

using Images
using Random

export permute_image

"""
Calculate first and last points after centering by specific length
"""
center_begin_end(actual::Int, required::Int) =
    round(Int, (actual - required) / 2) .+ [1, required]

"""
Resize the image
"""
function resize(img::Matrix, maxSize::Int)
    sz = round.(Int, size(img) .* (maxSize / max(size(img)...)))
    σ = map((o, n) -> 0.05 * o / n, size(img), sz)
    kern = KernelFactors.gaussian(σ)   # from ImageFiltering
    return imresize(imfilter(img, kern, NA()), sz)
end

"""
Transform zone number into matrix indices
"""
zone_to_coords(ind::Vector{Int}, step::Int) =
    ind .* step |> list -> map(x -> range(x + 1, stop = x + step), list)

"""
Perform image permutation

# Arguments
- `img::Matrix`: the source image as a matrix of colors
- `num::Int`: the number of parts for splitting each axis
"""
function permute_image(img::Matrix, num = 5::Int)::Matrix
    l = min(size(img)...)
    x = center_begin_end(size(img, 2), l)
    y = center_begin_end(size(img, 1), l)

    data_c = img[first(y):last(y), first(x):last(x)]
    img_round = resize(data_c, round(Int, ceil(l / num) * num))

    img_out = similar(img_round)
    step = round(Int, size(img_round, 1) / num)

    indices = [[i, j] for i = 0:(num-1) for j = 0:(num-1)]
    for (ind, ind_base) in zip(Random.shuffle(indices), indices)
        r_x, r_y = zone_to_coords(ind, step)
        rb_x, rb_y = zone_to_coords(ind_base, step)
        img_out[r_x, r_y] = img_round[rb_x, rb_y]
    end
    return img_out
end

include("server.jl")

end # module

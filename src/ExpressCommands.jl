module ExpressCommands

using AbInitioSoftwareBase: load, extension
using Comonicon: @cast, @main
import JLD2
using PrettyPrint: pprint
import TikzGraphs
import TikzPictures

"""
Print the `file` in a pretty format.

# Args

- `file`: the file to be printed. Available extensions are `.jld2`, `.json`, `.yaml`, `.yml` or `.toml`.
"""
@cast function show(file)
    ext = lowercase(extension(file))
    if ext == "jld2"
        pprint(JLD2.load(file))
    elseif ext in ("json", "yaml", "yml", "toml")
        data = load(file)
        pprint(data)
    else
        error("unsupported file extension `$ext`!")
    end
end

# @cast function install(plugin)
#     name = lowercase(plugin)
#     if name == "qe"
#         pkg"add https://github.com/MineralsCloud/QuantumESPRESSOExpress.jl.git"
#         # add("QuantumESPRESSOExpress")
#     else
#         error("unsupported plugin `$name`!")
#     end
# end

# @cast function uninstall(plugin)
#     name = lowercase(plugin)
#     if name == "qe"
#         rm("QuantumESPRESSOExpress")
#         gc()
#     else
#         error("unsupported plugin `$name`!")
#     end
# end

# @cast function use(plugin)
#     name = lowercase(plugin)
#     if name == "qe"
#         @set_preferences!("plugin" => "Quantum ESPRESSO")
#     else
#         error("unsupported plugin `$name`!")
#     end
# end

# macro load_plugin()
#     name = @load_preference("plugin")
#     if name == "Quantum ESPRESSO"
#         return :(@eval using QuantumESPRESSOExpress)
#     else
#         error("unsupported plugin `$name`!")
#     end
# end

"""
Plot the directed acyclic graph representing the relations between jobs in a `Workflow`.

# Args

- `file`: the file to be plotted. Available extension is `.jld2`.
"""
@cast function graph(file)
    ext = extension(file)
    graph = JLD2.load(file)["graph"]
    if ext == "jld2"
        TikzGraphs.save(
            TikzPictures.PDF(replace(file, ".jld2" => ".pdf")),
            TikzGraphs.plot(graph),
        )
    else
        error("unsupported extension `$ext`!")
    end
end

include("EOS.jl")
@cast EOS

include("Ph.jl")
@cast Ph

include("QHA.jl")
@cast QHA

function getmodule(recipe)
    recipe = lowercase(recipe)
    return if recipe == "eos"
        EOS
    elseif recipe in ("phonon dispersion", "vdos")
        Ph
    elseif recipe in ("qha single", "multi qha")
        QHA
    else
        error("recipe `$recipe` is not recognized!")
    end
end

"""
Run a configuration file (with an absolute path will be better).

# Args

- `file`: the file to be run. Acceptable extensions are `.json`, `.yaml`, `.yml`, or `.toml`.
"""
@cast function run(file)
    dict = load(file)
    mod = getmodule(dict["recipe"])
    return mod.run(file)
end

"""
The main command `xps`.
"""
@main

end

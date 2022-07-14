module ExpressCommands

using AbInitioSoftwareBase: load, extension
using Comonicon: @cast, @main
using EquationsOfStateOfSolids: Parameters, EquationOfStateOfSolids
import JLD2
using Pkg: add, rm, gc, @pkg_str
using Preferences: @set_preferences!, @load_preference
using PrettyPrint: pprint
using Serialization: deserialize
using SimpleWorkflows: Workflow
import TikzGraphs
import TikzPictures

"""
Print the `file` in a pretty format.

# Arguments
- `file`: the file to be printed. Available extensions are `.jls`, `.jld2`, `.json`, `.yaml`, `.yml` or `.toml`.
"""
@cast function print(file)
    ext = lowercase(extension(file))
    if ext == "jls"
        pprint(deserialize(file))
    elseif ext == "jld2"
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

# @cast function graph(file)
#     ext = extension(file)
#     workflow = deserialize(file)
#     typeassert(workflow, Workflow)
#     if ext == "jls"
#         TikzGraphs.save(
#             TikzPictures.PDF(replace(file, ".jls" => ".pdf")),
#             TikzGraphs.plot(workflow.graph),
#         )
#     else
#         error("unsupported extension `$ext`!")
#     end
# end

include("EOS.jl")
@cast EOS

include("Phonon.jl")
@cast Phonon

include("QHA.jl")
@cast QHA

function whichmodule(recipe)
    recipe = lowercase(recipe)
    return if recipe == "eos"
        EOS
    elseif recipe in ("phonon dispersion", "vdos")
        Phonon
    elseif recipe in ("qha single", "multi qha")
        QHA
    else
        error("workflow `$recipe` is not recognized!")
    end
end

@cast function run(cfgfile)
    dict = load(cfgfile)
    mod = whichmodule(dict["recipe"])
    return mod.run(cfgfile)
end

"""
The main command `xps`.
"""
@main

end
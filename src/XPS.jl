module XPS

using AbInitioSoftwareBase: load, extension
using Comonicon: @cast, @main
using EquationsOfStateOfSolids: Parameters, EquationOfStateOfSolids
using Pkg: @pkg_str
using PrettyPrint: pprint
using Serialization: deserialize

"""
Print the `file` in a pretty format.

# Arguments
- `file`: the file to be printed. Available extensions are `.jls`, `.json`, `.yaml`, `.yml` or `.toml`.
"""
@cast function print(file)
    ext = lowercase(extension(file))
    if ext == "jls"
        data = deserialize(file)
        if data isa Union{Parameters,EquationOfStateOfSolids}
            display(data)
        else
            pprint(data)
        end
    elseif ext in ("json", "yaml", "yml", "toml")
        data = load(file)
        pprint(data)
    else
        error("unsupported file extension `$ext`!")
    end
end

@cast function install(plugin)
    name = lowercase(plugin)
    if name == "qe"
        pkg"add QuantumESPRESSOExpress"
    else
        error("unsupported plugin `$name`!")
    end
end

@cast function uninstall(plugin)
    name = lowercase(plugin)
    if name == "qe"
        pkg"rm QuantumESPRESSOExpress"
        pkg"gc"
    else
        error("unsupported plugin `$name`!")
    end
end

include("EOS.jl")
@cast EOS

include("DFPT.jl")
@cast DFPT

"""
The main command `xps`.
"""
@main

end

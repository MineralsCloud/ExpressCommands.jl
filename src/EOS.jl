module EOS

using Comonicon: @cast
using EquationOfStateRecipes
using EquationsOfStateOfSolids: Parameters, EquationOfStateOfSolids, EnergyEquation
using Express.EquationOfStateWorkflow: Scf, VcOptim, FitEos
using Express.EquationOfStateWorkflow.DefaultActions: buildjob
using Express.EquationOfStateWorkflow.Recipes: buildworkflow
using QuantumESPRESSOExpress.EquationOfStateWorkflow
using Serialization: deserialize
using SimpleWorkflows: run!
import Plots

"""
Fit an equation of state from `cfgfile` for calculation `calc`.

# Arguments
- `calc`: the calculation type. Acceptable options are "scf" for self-consistent calculation and "optim" for structure optimizations.
- `cfgfile`: the file to be printed. Available extensions are `.jls`, `.json`, `.yaml`, `.yml` or `.toml`.
"""
@cast function fit(calc, cfgfile)
    calc = lowercase(calc)
    if calc == "scf"
        T = Scf
    elseif calc == "optim"
        T = VcOptim
    else
        throw(ArgumentError("unrecognized calculation type `$calc`!"))
    end
    job = buildjob(FitEos{T}(), cfgfile)
    run!(job)
    wait(job)
    display(getresult(job))
end

"""
Plot an equation of state from `file` to file "out".

# Arguments
- `file`: a `.jls` file that saves the equation of state.

# Options
- `-o, --out <path>`: the file path that saves the plot. Available extensions are `.pdf`, `.png`.
"""
@cast function plot(file; out = replace(file, ".jls" => ".pdf"))
    data = deserialize(file)
    if data isa Parameters
        eos = EnergyEquation(data)
    elseif data isa EquationOfStateOfSolids
        eos = data
    else
        error("unsupported type $(typeof(data))!")
    end
    Plots.plot(eos)
    Plots.savefig(out)
end

"""
Run a `config` file, better with absolute path.

# Arguments
- `config`: the file to be run. Available extensions are `.json`, `.yaml`, `.yml` or `.toml`.
"""
@cast function run(config)
    workflow = buildworkflow(config)
    run!(workflow)
    return workflow
end

end

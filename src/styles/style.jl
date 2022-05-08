abstract type AbstractStyleElement end

abstract type AbstractStyle{AbstractJavisGraphElement, AbstractStyleElement} end

elemtype(::AbstractStyle{ElemType, StyleType}) where {ElemType, StyleType} = ElemType

styletype(::AbstractStyle{ElemType, StyleType}) where {ElemType, StyleType} = StyleType

(style::AbstractStyle)(el::AbstractJavisGraphElement, 
f::GFrames) = add_style(style, el, f)

(style::AbstractStyle)(els::Array{T}, fs::Array{F}) where {T <: AbstractJavisGraphElement, F <: GFrames} = add_styles(style, els, fs)

abstract type AbstractIterativeStyle{ElemType, StyleType} <: AbstractStyle{ElemType, StyleType} end

# supported by only vertices
abstract type Fill <: AbstractStyleElement end
abstract type Border <: AbstractStyleElement end

# supported by both vertex and edges
abstract type Shape <: AbstractStyleElement end
abstract type Text <: AbstractStyleElement end

# supported by only edges
abstract type Arrow <: AbstractStyleElement end

function add_styles(style::AbstractStyle, els::Array{T}, fs::Array{F}) where {T <: AbstractJavisGraphElement, F <: GFrames}
    if !style.random
        for (i, el) in enumerate(els)
            add_style(style, el, fs[i])
        end
    elseif style isa AbstractIterativeStyle
        next = Base.iterate(style)
        for (i, el) in enumerate(els)
            item, state = next
            add_style(item, el, fs[i])
            next = Base.iterate(style, state)
        end
    end
end

macro register_style(expr::Expr)
    # use dump(expr) to analyse output
    @assert expr.head === :struct "Macro must be used on a style struct"
    typedef = expr.args[2]
    @assert typedef isa Expr &&
            typedef.head === :<: &&
            typedef.args[2] isa Expr &&
            typedef.args[2].args[1] ∈ [:AbstractStyle, :AbstractIterativeStyle] "Macro must be used on subtype of AbstractStyle"

    if typedef.args[1] isa Symbol
        name = typedef.args[1]
    else
        throw(ArgumentError("Cannot find the style name"))
    end

    fname = Symbol(lowercase(String(name)))
    return quote
        Base.@__doc__ $(esc(expr))
        # supports
        # circle(v, f; circle_args...) or Circle(v, f; circle_args...)
        # where v is a list of vertices and 
        # f is the list of frame ranges for them
        Base.@__doc__ $(esc(name))(el::AbstractJavisGraphElement, f::GFrames; kw...) = ($name(typeof(el); kw...)(el, f))
        Base.@__doc__ $(esc(fname))(els::Array{T}, fs::Array{F}; kw...) where {T <: AbstractJavisGraphElement, F <: GFrames} = ($name(eltype(els); kw...)(els, fs))
    end
end

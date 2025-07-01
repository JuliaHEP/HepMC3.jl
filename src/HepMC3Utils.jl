export CxxPtr, ConstCxxPtr, CxxRef, ConstCxxRef, move!

"""
    move!(o)
Move ownership of C++ object to receiver. The object cannot be used anymore after this call.
"""
function move!(a)
    r = CxxPtr(a)
    a.cpp_object = C_NULL
    return r
end

# Keep a reference to SafeCFunction(s) to avoid GC removing them
_cfuncs = Vector{CxxWrap.SafeCFunction}()
function preserve(f::CxxWrap.SafeCFunction)
    global _cfuncs
    push!(_cfuncs, f)
    return f
end
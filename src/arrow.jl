# Register our structs with Arrow.jl
Arrow.ArrowTypes.registertype!(Closed, Closed)
Arrow.ArrowTypes.registertype!(Open, Open)
Arrow.ArrowTypes.registertype!(Unbounded, Unbounded)
Arrow.ArrowTypes.registertype!(Interval, Interval)
Arrow.ArrowTypes.registertype!(AnchoredInterval, AnchoredInterval)

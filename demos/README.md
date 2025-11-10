# Ark.jl demos

This folder contains several stand-alone demos for Ark.jl.

## Usage

First, clone the repository and `cd` into it:

```
git clone https://github.com/mlange-42/Ark.jl.git
cd Ark.jl
```

Next, instantiate the demos project:

```
julia --project=demos -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
```

Run individual demos like this:

```
julia --project=demos demos/<DEMO>/main.jl
```

Most of the demos are interactive, so try hovering the mouse over the window.

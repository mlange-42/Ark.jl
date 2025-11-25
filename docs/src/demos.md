# Demos

The Ark repository contains a number of runnable [demos](https://github.com/mlange-42/Ark.jl/tree/main/demos).
These are listed here, alongside instructions for running them.

## Available demos

### Logo

An animated, interactive Ark.jl logo.
Use only the most basic features of Ark.

```@raw html
<div style="text-align: center;">
<img alt="Logo demo" src="https://github.com/user-attachments/assets/68de9316-0ed3-4b73-bc58-ed5830512ecb" />
</div>
```

[Source code](https://github.com/mlange-42/Ark.jl/tree/main/demos/logo)

## Running a demo

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



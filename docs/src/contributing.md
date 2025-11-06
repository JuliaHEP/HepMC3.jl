# Contributing to HepMC3.jl

Thank you for your interest in contributing to `HepMC3.jl`. We are very happy to get contributions for:

- Bug reports, for things that don't work properly.
- Feature requests, for things that `HepMC3.jl` could do in the future.
- Documentation improvements, for things that could be better explained.

We ask all contributors to follow the [Julia Community
Standards](https://julialang.org/community/standards/) - thank you!

## Issues: Bug Reports, Suggestions, Questions

Raise bug reports and general issues using the
[*issues*](https://github.com/JuliaHEP/HepMC3.jl/issues) feature. For bug
reports make sure that you:

- are using the latest released version
- explain how you are running the code
- state what the problem is clearly
- say what you would expect the behaviour to be

## New Features and Pull Requests

If you would like to contribute a new feature to the package it is a good idea
to open an issue first, so that you can discuss with the maintainers and check
that the feature is in-scope and general enough to warrant direct implementation
(as opposed to developing an extension package).

There are a few points to bear in mind for development listed below.

### Develop against `main`

Do your development against the head of the `main` branch so that your code will
work with all the other features that are in development at the moment. If
`main` is targetting a breaking change release, e.g., `v0.X+1.0` where `v0.X` is
the current version there may be a case for targetting the `release-0.X` branch
if your PR is a bug fix. Please discuss this with the maintainers.

If it takes a while to develop or implement review changes, rebase against
`main` as needed.

### Documentation

- **Document all public functions and types** using Julia docstrings that will
  be useful to users.
    - Add docstrings for internal functions too (unless these are trivial) with
      a focus on helping fellow developers.
- Update or add relevant sections in the documentation under `docs/src/` as needed.
- Provide clear explanations and usage examples where appropriate.

### Tests

- All new features **must include tests** in `test/`.
- The pattern used for implementation is to write a test in
  `test/test-NEW-FEATURE.jl` so that the test can be run standalone, and to add
  an `include("test-NEW-FEATURE.jl")` into `runtests.jl` for the CI.
- Ensure tests cover edge cases and typical usage.
- Run `] test HepMC3` or `julia --project test/runtests.jl` before
  submitting your PR to verify *all* tests pass.

### Examples

- Add or update usage examples in the documentation or in the `examples` directory.
- If your examples require extra packages, please put them into a subdirectory (`examples/FEATURE/...`) with their own `Project.toml`.
- Examples should be minimal, clear, and runnable.

### Formatting

The code in this repository is formatted with
[`JuliaFormatter`](https://github.com/domluna/JuliaFormatter.jl). Currently we
use *version 1* of the formatter so please use this too or the CI may complain.

#### Bootstrap

This is one way to do it:

```sh
$ julia --project=@juliaformatter
] add JuliaFormatter
] compat JuliaFormatter 1.0
] update

$ julia --project=@juliaformatter -e 'using JuliaFormatter; format(".")'
```

### Communication

- Open an issue to discuss major changes before starting work.
- Be responsive to feedback during the review process.

### Pull Request Checklist

Before submitting a PR, please ensure:

- [ ] Code is formatted and linted.
- [ ] All public APIs are documented.
- [ ] New/modified code is covered by tests.
- [ ] Examples are provided or updated.
- [ ] All tests pass locally.

## Some Development Tips

As far as possible we follow standard best practice for Julia code. In
particular you should be familiar with the following guidelines:

- [The Julia Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/)
- [Julia Performance Tips](https://docs.julialang.org/en/v1/manual/performance-tips/)

## C++ Wrapper Development

This package uses CxxWrap.jl to wrap the HepMC3 C++ library. If you need to add
new C++ functionality:

1. The wrapper code is generated using [WrapIt](https://github.com/grasph/wrapit)
2. Manual wrappers are in `gen/cpp/`
3. Generated bindings are in `gen/jl/`
4. See the `gen/` directory for build instructions

*Thank you for helping improve HepMC3.jl!*

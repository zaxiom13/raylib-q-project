# AGENTS Instructions

## Code Style Guidelines

- Keep files small and focused. Don't be shy about creating new files and directories.
- Split large files rather than making them "more concise" - prefer multiple small files over one giant file.
- Split any file that grows beyond 500 lines into smaller modules/files.
- Happily create new files, folders, and nested directories whenever that improves modularity and maintainability.
- For user-facing q examples (not internal codebase), each definition in a snippet must fit on a single line.

## Required workflow after every change

- Always run `make install` after making any project changes so the latest shim and q init script are installed to `~/.kx`.
- Preferred command sequence:
  - `make`
  - `make test`
  - `make install`

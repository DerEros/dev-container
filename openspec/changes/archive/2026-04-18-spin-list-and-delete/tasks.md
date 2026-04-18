## 1. Subcommand Dispatch

- [x] 1.1 Add a `case` block at the top of `spin.sh` that checks `$1` against `list` and `delete` before the existing project-name logic

## 2. List Command

- [x] 2.1 Implement the `list` handler: run `docker ps -a --filter "name=^dev-"`, strip the `dev-` prefix from each name, and print `<project-name>    running|stopped`

## 3. Delete Command

- [x] 3.1 Implement the `delete` handler: require a name argument (print usage + exit 1 if missing)
- [x] 3.2 Add y/N confirmation prompt before removing the container
- [x] 3.3 Stop and remove the container if it exists; silently succeed if it does not
- [x] 3.4 Implement `--purge` flag detection within the delete handler
- [x] 3.5 Add second confirmation for purge (type the project name to confirm)
- [x] 3.6 Remove `~/workspace/<name>/` and `~/.dev-containers/<name>/` if they exist, silently skip if not

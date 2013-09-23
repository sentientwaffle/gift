{exec} = require 'child_process'
Repo   = require './repo'

# Public: Create a Repo from the given path.
# 
# Returns Repo.
module.exports = Git = (path, bare=false) ->
  return new Repo path, bare


# Public: Initialize a git repository.
# 
# path     - The directory to run `git init .` in.
# bare     - Create a bare repository when true.
# callback - Receives `(err, repo)`.
# 
Git.init = (path, bare, callback) ->
  [bare, callback] = [callback, bare] if !callback
  if bare
    bash = "git init --bare ."
  else
    bash = "git init ."
  exec bash, {cwd: path}
  , (err, stdout, stderr) ->
    return callback err if err
    return callback err, (new Repo path, bare)

# Public: Clone a git repository.
# 
# repository - The repository to clone from.
# path       - The directory to clone into.
# callback   - Receives `(err, repo)`.
# 
Git.clone = (repository, path, callback) ->
  bash = "git clone #{repository} #{path}"
  exec bash, (err, stdout, stderr) ->
    return callback err if err
    return callback err, (new Repo path)
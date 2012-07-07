# Public: Create a Status.
# 
# repo     - A Repo.
# callback - Receives `(err, status)`
# 
module.exports = S = (repo, callback) ->
  repo.git "status", (err, stdout, stderr) ->
    status = new Status repo
    status.parse stdout
    return callback err, status


BEGIN_STAGED    = [
  "# Changes to be committed:"
]
BEGIN_UNSTAGED  = [
  "# Changed but not updated:"
  "# Changes not staged for commit:"
]
BEGIN_UNTRACKED = [
  "# Untracked files:"
]
FILE            = /^#\s+([^\s]+)[:]\s+(.+)$/
TYPES =
  added:    "A"
  modified: "M"
  deleted:  "D"

S.Status = class Status
  constructor: (@repo) ->
  
  # Internal: Parse the status from stdout of a `git status` command.
  parse: (text) ->
    @files = {}
    @clean = true
    state  = null
    for line in text.split("\n")
      if ~BEGIN_STAGED.indexOf(line)
        state = "staged"
        @clean = false
      else if ~BEGIN_UNSTAGED.indexOf(line)
        state = "unstaged"
        @clean = false
      else if ~BEGIN_UNTRACKED.indexOf(line)
        state = "untracked"
        @clean = false
      else if state && match = FILE.exec(line)
        file = match[2]
        data = switch state
          when "staged"    then {staged: true,  tracked: true}
          when "unstaged"  then {staged: false, tracked: true}
        data.type    = TYPES[match[1]]
        @files[file] = data
      else if state == "untracked" && (match = /^#\s+([^\s]+)$/.exec(line))
        file = match[1]
        @files[file] = {tracked: false}
    return

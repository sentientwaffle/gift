Blob = require './blob'

module.exports = class Diff
  constructor: (@repo, @a_path, @b_path, a_blob, b_blob
  , @a_mode, @b_mode, @new_file, @deleted_file, @diff
  , @renamed_file=false, @similarity_index=0) ->
    @a_blob = new Blob @repo, {id: a_blob} if a_blob
    @b_blob = new Blob @repo, {id: b_blob} if b_blob
  
  
  toJSON: ->
    {@a_path, @b_path, @a_mode, @b_mode, @new_file
    , @deleted_file, @diff, @renamed_file, @similarity_index}
  
  # Public: Parse the Diffs from the command output.
  # 
  # text - String stdout of a `git diff` command.
  # 
  # Returns Array of Diff.
  @parse: (repo, text) ->
    lines = text.split "\n"
    diffs = []
    
    while lines.length && lines[0]
      [m, a_path, b_path] = ///^diff\s--git\s"?a/(.+?)"?\s"?b/(.+)"?$///.exec lines.shift()
      
      if /^old mode/.test lines[0]
        [m, a_mode] = /^old mode (\d+)/.exec lines.shift()
        [m, b_mode] = /^new mode (\d+)/.exec lines.shift()
      
      if !lines.length || /^diff --git/.test(lines[0])
        diffs.push new Diff(repo, a_path, b_path, null, null, a_mode, b_mode, false, false, null)
        continue
      
      sim_index    = 0
      new_file     = false
      deleted_file = false
      renamed_file = false
      
      if /^new file/.test lines[0]
        [m, b_mode] = /^new file mode (.+)$/.exec lines.shift()
        a_mode      = null
        new_file    = true
      else if /^deleted file/.test lines[0]
        [m, a_mode]    = /^deleted file mode (.+)$/.exec lines.shift()
        b_mode         = null
        deleted_file   = true
      else if m = /^similarity index (\d+)\%/.exec(lines[0])
        sim_index    = m[1].to_i
        renamed_file = true
        # shift away the 2 `rename from/to ...` lines
        lines.shift()
        lines.shift()
      
      [m, a_blob, b_blob, b_mode] = ///^index\s([0-9A-Fa-f]+)\.\.([0-9A-Fa-f]+)\s?(.+)?$///.exec lines.shift()
      b_mode = b_mode.trim() if b_mode
      
      diff_lines = []
      while lines[0] && !/^diff/.test(lines[0])
        diff_lines.push lines.shift()
      diff = diff_lines.join "\n"
      
      diffs.push new Diff(repo, a_path, b_path, a_blob, b_blob, a_mode, b_mode, new_file, deleted_file, diff, renamed_file, sim_index)
    
    return diffs


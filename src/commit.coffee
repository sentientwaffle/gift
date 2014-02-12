_     = require 'underscore'
Actor = require './actor'
Tree  = require './tree'

module.exports = class Commit
  constructor: (@repo, @id, parents, tree, @author, @authored_date, @committer, @committed_date, @message) ->
    # Public: Get the commit's Tree.
    # 
    # Returns Tree.
    @tree = _.memoize => (new Tree @repo, tree)
    
    # Public: Get the Commit's parent Commits.
    # 
    # Returns an Array of Commits.
    @parents = _.memoize =>
      _.map parents, (parent) =>
        new Commit @repo, parent
  
  
  toJSON: ->
    {@id, @author, @authored_date, @committer, @committed_date, @message}
  
  
  # Public: Find the matching commits.
  # 
  # callback - Receives `(err, commits)`
  # 
  @find_all: (repo, ref, options, callback) ->
    options = _.extend {pretty: "raw"}, options
    repo.git "rev-list", options, ref
    , (err, stdout, stderr) =>
      return callback err if err
      return callback null, @parse_commits(repo, stdout)
  
  
  @find: (repo, id, callback) ->
    options = {pretty: "raw", "max-count": 1}
    repo.git "rev-list", options, id
    , (err, stdout, stderr) =>
      return callback err if err
      return callback null, @parse_commits(repo, stdout)[0]
  
  
  @find_commits: (repo, ids, callback) ->
    commits = []
    next = (i) ->
      if id = ids[i]
        Commit.find repo, id, (err, commit) ->
          return callback err if err
          commits.push commit
          next i + 1
      # Done: all commits loaded.
      else
        callback null, commits
    next 0
  
  
  # Internal: Parse the commits from `git rev-list`
  # 
  # Return Commit[]
  @parse_commits: (repo, text) ->
    commits = []
    lines   = text.split "\n"
    while lines.length
      id   = _.last lines.shift().split(" ")
      break if !id
      tree = _.last lines.shift().split(" ")
      
      parents = []
      while /^parent/.test lines[0]
        parents.push _.last lines.shift().split(" ")
      
      author_line = lines.shift()
      if !/^committer /.test(lines[0])
        author_line.push lines.shift()
      [author, authored_date] = @actor author_line
      
      committer_line = lines.shift()
      if lines[0] && !/^encoding/.test(lines[0])
        committer_line.push lines.shift()
      [committer, committed_date] = @actor committer_line
      
      # not doing anything with this yet, but it's sometimes there
      if /^encoding/.test lines.first
        encoding = _.last lines.shift().split(" ")
      
      lines.shift()
      
      message_lines = []
      while /^ {4}/.test lines[0]
        message_lines.push lines.shift()[4..-1]
      
      while lines[0]? && !lines[0].length
        lines.shift()

      commits.push new Commit(repo, id, parents, tree, author, authored_date, committer, committed_date, message_lines.join("\n"))
    return commits
  
  
  # Internal: Parse the actor.
  # 
  # Returns [String name and email, Date]
  @actor: (line) ->
    [m, actor, epoch] = /^.+? (.*) (\d+) .*$/.exec line
    return [Actor.from_string(actor), new Date(1000 * +epoch)]

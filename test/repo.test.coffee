should   = require 'should'
fs       = require 'fs'
fixtures = require './fixtures'
git      = require '../src'
Commit   = require '../src/commit'
Tree     = require '../src/tree'
Diff     = require '../src/diff'
Tag      = require '../src/tag'
Status   = require '../src/status'

{Ref, Head} = require '../src/ref'
{exec}      = require 'child_process'

describe "Repo", ->
  describe "#commits", ->
    describe "with only a callback", ->
      repo    = fixtures.branched
      commits = null
      before (done) ->
        repo.commits (err, _commits) ->
          commits = _commits
          done err
      
      it "passes an Array", ->
        commits.should.be.an.instanceof Array
      
      it "is a list of commits", ->
        commits[0].id.should.eql "913318e66e9beed3e89e9c402c1d6585ef3f7e6f"
        commits[0].repo.should.eql repo
        commits[0].author.name.should.eql "sentientwaffle"
        commits[0].committer.name.should.eql "sentientwaffle"
        commits[0].authored_date.should.be.an.instanceof Date
        commits[0].committed_date.should.be.an.instanceof Date
        commits[0].parents().should.be.an.instanceof Array
        commits[0].message.should.eql "add a sub dir"
    
    describe "specify a branch", ->
      repo    = fixtures.branched
      commits = null
      before (done) ->
        repo.commits "something", (err, _commits) ->
          commits = _commits
          done err
      
      # The first commit ...
      it "is the latest commit", ->
        commits[0].message.should.eql "2"
      
      it "has a parent commit", ->
        commits[0].parents().should.have.lengthOf 1
        commits[0].parents()[0].id.should.eql commits[1].id
    
    describe "specify a tag", ->
      repo    = fixtures.tagged
      commits = null
      before (done) ->
        repo.commits "tag-1", (err, _commits) ->
          commits = _commits
          done err
      
      it "is the latest commit on the tag", ->
        commits[0].message.should.include "commit 5"
    
    describe "limit the number of commits", ->
      repo    = fixtures.tagged
      commits = null
      before (done) ->
        repo.commits "master", 2, (err, _commits) ->
          commits = _commits
          done err
      
      it "returns 2 commits", ->
        commits.should.have.lengthOf 2
    
    describe "skip commits", ->
      repo    = fixtures.tagged
      commits = null
      before (done) ->
        repo.commits "master", 1, 2, (err, _commits) ->
          commits = _commits
          done err
      
      it "returns 2 commits", ->
        commits[0].message.should.include "commit 4"
  
  
  describe "#tree", ->
    repo = fixtures.branched
    describe "master", ->
      it "is a Tree", ->
        repo.tree().should.be.an.instanceof Tree
      
      it "checks out branch:master", (done) ->
        repo.tree().blobs (err, blobs) ->
          blobs[0].data (err, data) ->
            data.should.include "Bla"
            data.should.not.include "Bla2"
            done err
    
    describe "specific branch", ->
      it "is a Tree", ->
        repo.tree("something").should.be.an.instanceof Tree
      
      it "checks out branch:something", (done) ->
        repo.tree("something").blobs (err, blobs) ->
          blobs[0].data (err, data) ->
            data.should.include "Bla2"
            done err
  
  
  describe "#diff", ->
    repo = fixtures.branched
    describe "between 2 branches", ->
      diffs = null
      before (done) ->
        repo.diff "something", "master", (err, _diffs) ->
          diffs = _diffs
          done err
      
      it "is passes an Array of Diffs", ->
        diffs.should.be.an.instanceof Array
        diffs[0].should.be.an.instanceof Diff
      
      # The first diff...
      it "modifies the README.md file", ->
        diffs[0].a_path.should.eql "README.md"
        diffs[0].b_path.should.eql "README.md"
      
      # The second diff...
      it "creates some/hi.txt", ->
        diffs[1].new_file.should.be.true
        diffs[1].b_path.should.eql "some/hi.txt"
  
  
  describe "#remotes", ->
    describe "in a repository with remotes", ->
      repo    = fixtures.remotes
      remotes = null
      before (done) ->
        repo.remotes (err, _remotes) ->
          remotes = _remotes
          done err
      
      it "is an Array of Refs", ->
        remotes.should.be.an.instanceof Array
        remotes[0].should.be.an.instanceof Ref
      
      it "contains the correct Refs", ->
        remotes[0].commit.id.should.eql "bdd3996d38d885e18e5c5960df1c2c06e34d673f"
        remotes[0].name.should.eql "origin/HEAD"
        remotes[1].commit.id.should.eql "bdd3996d38d885e18e5c5960df1c2c06e34d673f"
        remotes[1].name.should.eql "origin/master"
    
    describe "when there are no remotes", ->
      repo = fixtures.branched
      it "is an empty Array", ->
        repo.remotes (err, remotes) ->
          remotes.should.eql []
  
  
  describe "#remote_list", ->
    describe "in a repository with remotes", ->
      repo    = fixtures.remotes
      remotes = null
      before (done) ->
        repo.remote_list (err, _remotes) ->
          remotes = _remotes
          done err
      
      it "is a list of remotes", ->
        remotes.should.have.lengthOf 1
        remotes[0].should.eql "origin"
    
    describe "when there are no remotes", ->
      repo = fixtures.branched
      it "is an empty Array", ->
        repo.remote_list (err, remotes) ->
          remotes.should.eql []
  
  
  describe "#tags", ->
    describe "a repo with tags", ->
      repo = fixtures.tagged
      tags = null
      before (done) ->
        repo.tags (err, _tags) ->
          tags = _tags
          done err
      
      it "is an Array of Tags", ->
        tags.should.be.an.instanceof Array
        tags[0].should.be.an.instanceof Tag
      
      it "is the correct tag", ->
        tags[0].name.should.eql "tag-1"
    
    describe "a repo without tags", ->
      repo = fixtures.branched
      it "is an empty array", (done) ->
        repo.tags (err, tags) ->
          tags.should.eql []
          done err
  
  describe "#create_tag", ->
    repo    = null
    git_dir = __dirname + "/fixtures/junk_create_tag"
    before (done) ->
      fs.mkdir git_dir, 0755, (err) ->
        return done err if err
        git.init git_dir, (err) ->
          return done err if err
          repo = git(git_dir)
          fs.writeFileSync "#{git_dir}/foo.txt", "cheese"
          repo.add "#{git_dir}/foo.txt", (err) ->
            return done err if err
            repo.commit "initial commit", {all: true}, done

    after (done) ->
      exec "rm -rf #{ git_dir }", done

    it "creates a tag", (done) ->
      repo.create_tag "foo", done
  
  describe "#delete_tag", ->
    describe "deleting a tag that does not exist", ->
      repo = fixtures.branched
      it "passes an error", (done) ->
        repo.delete_tag "nonexistant-tag", (err) ->
          should.exist err
          done()
  
  
  describe "#branches", ->
    repo     = fixtures.branched
    branches = null
    before (done) ->
      repo.branches (err, _branches) ->
        branches = _branches
        done err
    
    it "is an Array of Heads", ->
      branches.should.be.an.instanceof Array
      branches[0].should.be.an.instanceof Head
    
    it "has the correct branches", ->
      branches[0].name.should.eql "master"
      branches[1].name.should.eql "something"
  
  
  describe "#branch", ->
    describe "when a branch name is given", ->
      repo   = fixtures.branched
      branch = null
      before (done) ->
        repo.branch "something", (err, b) ->
          branch = b
          done err
      
      it "is a Head", ->
        branch.should.be.an.instanceof Head
      
      it "has the correct name", ->
        branch.name.should.eql "something"
    
    describe "when no branch name is given", ->
      repo   = fixtures.branched
      branch = null
      before (done) ->
        repo.branch (err, b) ->
          branch = b
          done err
      
      it "has the correct name", ->
        branch.name.should.eql "master"
    
    describe "an invalid branch", ->
      repo = fixtures.branched
      it "passes an error", (done) ->
        repo.branch "nonexistant-branch", (err, b) ->
          should.exist err
          should.not.exist b
          done()
  
  
  describe "#delete_branch", ->
    describe "a branch that does not exist", ->
      repo = fixtures.branched
      it "passes an error", (done) ->
        repo.delete_branch "nonexistant-branch", (err) ->
          should.exist err
          done()
  

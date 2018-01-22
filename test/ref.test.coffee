_        = require 'underscore'
should   = require 'should'
fixtures = require './fixtures'
git      = require '../src'
Commit   = require '../src/commit'

{Ref, Head} = require '../src/ref'

describe "Ref", ->
  describe ".find_all", ->
    describe "find remotes", ->
      repo    = fixtures.remotes
      remotes = null
      before (done) ->
        Ref.find_all repo, "remote", Ref, (err, _remotes) ->
          remotes = _remotes
          done err

      it "is an Array of Refs", ->
        remotes.should.be.an.instanceof Array
        remotes[0].should.be.an.instanceof Ref

      it "the first item is a remote", ->
        remotes[0].name.should.eql "origin/HEAD"
        remotes[0].commit.should.be.an.instanceof Commit

      it "the second item is a remote", ->
        remotes[1].name.should.eql "origin/master"
        remotes[1].commit.should.be.an.instanceof Commit


describe "Head", ->
  describe ".find_all", ->
    repo  = fixtures.branched
    heads = null
    before (done) ->
      Head.find_all repo, (err, h) ->
        heads = h
        done err

    it "is an Array of Heads", ->
      heads.should.be.an.instanceof Array
      heads[0].should.be.an.instanceof Head

    it "contains the branches", ->
      heads.should.have.lengthOf 2
      names = _.map heads, ((b) -> b.name)
      names.should.containEql "master"
      names.should.containEql "something"


  describe ".current", ->
    repo   = fixtures.branched
    branch = null
    before (done) ->
      Head.current repo, (err, b) ->
        branch = b
        done err

    it "is a Head", ->
      branch.should.be.an.instanceof Head

    it "has the correct name", ->
      branch.name.should.eql "master"

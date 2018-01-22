should = require 'should'
Actor  = require '../src/actor'

describe "Actor", ->
  describe ".constructor", ->
    actor = new Actor "bob", "bob@example.com"
    it "assigns @name", ->
      actor.name.should.eql "bob"

    it "assigns @email", ->
      actor.email.should.eql "bob@example.com"


  describe "#toString", ->
    actor = new Actor "bob", "bob@example.com"

    it "is a string representation of the actor", ->
      actor.toString().should.eql "bob <bob@example.com>"


  describe "#hash", ->
    actor = new Actor "bob", "bob@example.com"

    it "is the md5 hash of the email", ->
      actor.hash.should.eql "4b9bb80620f03eb3719e0a061c14283d"


  describe ".from_string", ->
    describe "with a name and email", ->
      actor = Actor.from_string "bob <bob@example.com>"
      it "parses the name", ->
        actor.name.should.eql "bob"

      it "parses the email", ->
        actor.email.should.eql "bob@example.com"

    describe "with only a name", ->
      actor = Actor.from_string "bob"
      it "parses the name", ->
        actor.name.should.eql "bob"

      it "does not parse the email", ->
        should.not.exist actor.email

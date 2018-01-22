should   = require 'should'
fixtures = require './fixtures'
git      = require '../src'
Diff     = require '../src/diff'
Blob     = require '../src/blob'


describe "Diff", ->
  describe ".parse", ->
    describe "simple editing", ->
      repo   = fixtures.tagged
      stdout = """
          diff --git a/file.txt b/file.txt
          index d00491f..48082f7 100644
          --- a/file.txt
          +++ b/file.txt
          @@ -1 +1 @@
          -1
          +12
        """
      diffs = Diff.parse repo, stdout

      it "is an Array of Diffs", ->
        diffs.should.be.an.instanceof Array
        diffs[0].should.be.an.instanceof Diff

      it "has one diff", ->
        diffs.should.have.lengthOf 1

      describe "the first diff", ->
        diff = diffs[0]

        it "has the repo", ->
          diff.repo.should.eql repo

        for blob in ["a_blob", "b_blob"]
          it "has a #{blob}", ->
            diff[blob].should.be.an.instanceof Blob

        for path in ["a_path", "b_path"]
          it "has a #{path}", ->
            diff[path].should.eql "file.txt"

        it "has a b_mode", ->
          diff.b_mode.should.eql "100644"

        for change in ["new_file", "renamed_file", "deleted_file"]
          it "#{change} is false", ->
            diff[change].should.be.false

        it "has a similarity_index of 0", ->
          diff.similarity_index.should.eql 0

  describe ".parse_raw", ->
    describe "simple editing", ->
      repo = fixtures.tagged
      stdout = """
        :100644 100644 95f6539... 0466f13... M  file.txt
      """
      diffs = Diff.parse_raw repo, stdout

      it "is an Array of Diffs", ->
        diffs.should.be.an.instanceof Array
        diffs[0].should.be.an.instanceof Diff

      it "has one diff", ->
        diffs.should.have.lengthOf 1

      describe "the first diff", ->
        diff = diffs[0]

        it "has the repo", ->
          diff.repo.should.eql repo

        for blob in ["a_blob", "b_blob"]
          it "has a #{blob}", ->
            diff[blob].should.be.an.instanceof Blob

        for path in ["a_path", "b_path"]
          it "has a #{path}", ->
            diff[path].should.eql "file.txt"

        it "has a b_mode", ->
          diff.b_mode.should.eql "100644"

        for change in ["new_file", "renamed_file", "deleted_file"]
          it "#{change} is false", ->
            diff[change].should.be.false

        it "has a similarity_index of 0", ->
          diff.similarity_index.should.eql 0

    describe "delete a file", ->
      repo   = fixtures.branched
      stdout = """
          diff --git a/README.md b/README.md
          index e4ff69d..c0efd1c 100644
          --- a/README.md
          +++ b/README.md
          @@ -1 +1 @@
          -Bla
          +Bla2
          diff --git a/some/hi.txt b/some/hi.txt
          deleted file mode 100644
          index 6f1de24..0000000
          --- a/some/hi.txt
          +++ /dev/null
          @@ -1 +0,0 @@
          -!!!
        """
      diffs = Diff.parse repo, stdout

      it "has 2 diffs", ->
        diffs.should.have.lengthOf 2

      describe "the second diff", ->
        diff = diffs[1]
        it "deletes a file", ->
          diff.deleted_file.should.be.true

    describe "create a file", ->
      repo   = fixtures.branched
      stdout = """
          diff --git a/some/hi.txt b/some/hi.txt
          new file mode 100644
          index 0000000..6f1de24
          --- /dev/null
          +++ b/some/hi.txt
          @@ -0,0 +1 @@
          +!!!
        """
      diffs = Diff.parse repo, stdout

      it "creates a file", ->
        diffs[0].new_file.should.be.true



    if a_blob isnt null
      @a_blob = new Blob @repo, {id: a_blob}
      @a_sha = a_blob
    if b_blob isnt null
      @b_blob = new Blob @repo, {id: b_blob}
      @b_sha = b_blob
      # FIXME shift is O(n), so iterating n over O(n) operation might be O(n^2)
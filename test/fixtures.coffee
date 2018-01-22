git = require '../src'

dir = "#{__dirname}/fixtures"

module.exports =
  branched:  git("#{dir}/branched", true)
  checkout:  git("#{dir}/checkout", true)
  gpgsigned: git("#{dir}/gpgsigned", true)
  remotes:   git("#{dir}/remotes", true)
  simple:    git("#{dir}/simple", true)
  status:    git("#{dir}/status", true)
  submodule: git("#{dir}/submodule", true)
  tagged:    git("#{dir}/tagged", true)
  noBranch:  git("#{dir}/no_branch", true)

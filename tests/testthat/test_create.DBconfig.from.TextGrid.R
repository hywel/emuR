##' testthat tests for convert.TextGridCollection.to.emuDB
##'
##' @author Raphael Winkelmann
require(RSQLite)

context("testing create.DBconfig.from.TextGrid function")

path2tg = system.file("extdata/legacy_emu/DBs/ae/labels/msajc003.TextGrid", package = "emuR")

dbName = 'test12'

##############################
test_that("test that correct values are set for msajc003", {
  conf = create.DBconfig.from.TextGrid(path2tg, dbName)
  expect_equal(length(conf$linkDefinitions), 0)
  expect_equal(length(conf$ssffTrackDefinitions), 0)
  expect_equal(length(conf$levelDefinitions), 11)
  expect_equal(conf$mediafileExtension, 'wav')
  
  expect_equal(conf$levelDefinitions[[1]]$name, 'Utterance')
  expect_equal(conf$levelDefinitions[[1]]$type, 'SEGMENT')
  expect_equal(conf$levelDefinitions[[1]]$attributeDefinitions[[1]]$name, 'Utterance')
  expect_equal(conf$levelDefinitions[[1]]$attributeDefinitions[[1]]$type, 'STRING')
  
})

##############################
test_that("test only correct tiers are extracted if tierNames is set", {
  conf = create.DBconfig.from.TextGrid(path2tg, dbName, c("Phonetic", "Tone"))

  expect_equal(conf$levelDefinitions[[1]]$name, 'Phonetic')
  expect_equal(conf$levelDefinitions[[1]]$type, 'SEGMENT')
  expect_equal(conf$levelDefinitions[[1]]$attributeDefinitions[[1]]$name, 'Phonetic')
  expect_equal(conf$levelDefinitions[[1]]$attributeDefinitions[[1]]$type, 'STRING')

  expect_equal(conf$levelDefinitions[[2]]$name, 'Tone')
  expect_equal(conf$levelDefinitions[[2]]$type, 'EVENT')
  expect_equal(conf$levelDefinitions[[2]]$attributeDefinitions[[1]]$name, 'Tone')
  expect_equal(conf$levelDefinitions[[2]]$attributeDefinitions[[1]]$type, 'STRING')
  
})

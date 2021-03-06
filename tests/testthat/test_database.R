require(testthat)
require(compare)
require(wrassp)
require(emuR)

context("testing database functions")

.aeSampleRate=20000

.test_emu_ae_db=NULL
.test_emu_ae_db_dir=NULL
## "private" function does not work with R CMD check !
test_load_ae_database<-function(){
  if(is.null(.test_emu_ae_db)){
    legacyDbEmuAeTpl <- system.file("extdata/legacy_emu/DBs/ae","ae.tpl", package="emuR")
    .test_emu_ae_db_dir<<-tempfile('test_emu_ae')
    convert.legacyEmuDB.to.emuDB(emuTplPath=legacyDbEmuAeTpl,targetDir=.test_emu_ae_db_dir,verbose=FALSE)
    .test_emu_ae_db<<-load.emuDB(file.path(.test_emu_ae_db_dir,'ae'),verbose=FALSE)
    #return(load.database(file.path(aeTmpDir,'ae')))
  } 
 return(.test_emu_ae_db)
}

test_that("function get.legacy.file.path()",{
  primaryTrackFilePath=get.legacy.file.path("/path/to/db",'BLOCK*/SES*',c('BLOCK30','SES3042','0001abc'),'wav')
  expect_equal(primaryTrackFilePath,"/path/to/db/BLOCK30/SES3042/0001abc.wav")
  
  signalTrackFilePath=get.legacy.file.path("/path/to/db",'F0',c('BLOCK30','SES3042','0001abc'),'f0')
  expect_equal(signalTrackFilePath,"/path/to/db/F0/0001abc.f0")
})

test_that("Load example database ae",{

  ae=test_load_ae_database()
  expect_that(ae[['name']],is_equivalent_to('ae'))
  
})

test_that("Data types are correct",{
  
  ae=test_load_ae_database()
  expect_that(ae[['name']],is_equivalent_to('ae'))
  items=ae[['items']]
  expect_that(class(items[['seqIdx']]),is_equivalent_to('integer'))
  expect_that(class(items[['itemID']]),is_equivalent_to('integer'))
  expect_that(class(items[['sampleRate']]),is_equivalent_to('numeric'))
  expect_that(class(items[['samplePoint']]),is_equivalent_to('integer'))
  expect_that(class(items[['sampleStart']]),is_equivalent_to('integer'))
  expect_that(class(items[['sampleDur']]),is_equivalent_to('integer'))
  
  labels=ae[['labels']]
  expect_that(class(labels[['labelIdx']]),is_equivalent_to('integer'))
  
  links=ae[['links']]
  expect_that(class(links[['fromID']]),is_equivalent_to('integer'))
  expect_that(class(links[['toID']]),is_equivalent_to('integer'))
})

test_that("Test ae samples",{
  
  ae=test_load_ae_database()
  aeSess=ae[['sessions']][[1]]
  aeB1=aeSess[['bundles']][[1]]
  expect_equivalent(aeB1[['sampleRate']],.aeSampleRate)
  
  halfSample=0.5/.aeSampleRate
  msajc015_lab_values=c(0.300000,0.350276,0.425417,0.496601,0.558601,0.639601,0.663601,0.706601,0.806601,1.006101,1.085101,1.097601,1.129101,1.160101,1.213101,1.368101,1.413095,1.449550,1.464601,1.500731,1.578583,1.623228,1.653718,1.717601,1.797463,1.828601,1.903635,2.070101,2.104101,2.154601,2.200911,2.226601,2.271132,2.408601,2.502214,2.576618,2.606558,2.693704,2.749004,2.780766,2.798504,2.876593,2.958101,3.026668,3.046168,3.067703,3.123168,3.238668,3.297668,3.456899) 
  msajc015_tone_events=c(0.531305,1.486760,1.609948,2.445220,2.910929,3.110782,3.262078)
  lvCnt=length(msajc015_lab_values)
  teCnt=length(msajc015_tone_events)
  msajc015_phonetic=ae[['items']][ae[['items']][['bundle']]=="msajc015" & ae[['items']][['level']]=='Phonetic',]
  # order by sequence index
  msajc015_phonetic_ordered=msajc015_phonetic[order(msajc015_phonetic[['seqIdx']]),]
  rc=nrow(msajc015_phonetic_ordered)
  expect_equivalent(rc+1,lvCnt)
  
  msajc015_tone=ae[['items']][ae[['items']][['bundle']]=="msajc015" & ae[['items']][['level']]=='Tone',]
  msajc015_tone_ordered=msajc015_tone[order(msajc015_tone[['seqIdx']]),]
  lvSq=1:rc
  
  # check sequence
  for(i in lvSq){
   
    poSampleStart=msajc015_phonetic_ordered[i,'sampleStart']
    poSampleDur=msajc015_phonetic_ordered[i,'sampleDur']
    if(i<rc){
      poNextSampleStart=msajc015_phonetic_ordered[i+1,'sampleStart']
      # TODO
      expect_equivalent(poNextSampleStart,poSampleStart+poSampleDur+1)
      #expect_equivalent(poNextSampleStart,poSampleStart+poSampleDur+1)
    }
  }
  # check segment boundaries
  for(i in lvSq){
    lv=msajc015_lab_values[i]
    poSampleStart=msajc015_phonetic_ordered[i,'sampleStart']
    poSampleDur=msajc015_phonetic_ordered[i,'sampleDur']
    poStart=(poSampleStart+0.5)/.aeSampleRate
    absFail=abs(poStart-lv)
    # accept deviation of at least half a sample
    expect_less_than(absFail,halfSample)
  }
  # and the last value
  lv=msajc015_lab_values[lvCnt]
  poSampleEnd=msajc015_phonetic_ordered[rc,'sampleStart']+msajc015_phonetic_ordered[rc,'sampleDur']+1
  poEnd=(poSampleEnd+0.5)/.aeSampleRate
  absFail=abs(poEnd-lv)
  # accept deviation of at least half a sample
  expect_less_than(absFail,halfSample)
  
  # check tone events
  teS=1:teCnt
  for(i in teS){
    teTime=msajc015_tone_events[i]
    teLSample=msajc015_tone_ordered[i,'samplePoint']
    teLTime=teLSample/.aeSampleRate
    absFail=abs(teLTime-teTime)
    expect_less_than(absFail,halfSample)
  }
  
})

test_that("Test ae modify",{
  ae=test_load_ae_database()
  expect_equivalent(nrow(ae[['items']]),736)
  expect_equivalent(nrow(ae[['links']]),785)
  expect_equivalent(nrow(ae[['linksExt']]),3950)
  b015=get.bundle(ae,'0000','msajc015')
  # select arbitrary item
  b015m=b015
  phoneticLvlIt10=b015m[['levels']][['Phonetic']][['items']][[10]]
  lblOrg=phoneticLvlIt10[['labels']][[1]][['value']]
  b015m[['levels']][['Phonetic']][['items']][[10]][['labels']][[1]][['value']]='test!!'
  aem=store.bundle.annotation(ae,b015m)
  
  expect_equivalent(nrow(aem[['items']]),736)
  expect_equivalent(nrow(aem[['links']]),785)
  expect_equivalent(nrow(aem[['linksExt']]),3950)
  
  # items should not be equal
  # Note: test doe not work without redundant label in items tbale anymore
  #cm1=compare(ae$items,aem$items,allowAll=TRUE)
  #expect_false(cm1$result)
  # links are not changed, should be equal to original
  cml1=compare(ae$links,aem$links,allowAll=TRUE)
  expect_true(cml1$result)
  cmle1=compare(ae$linksExt,aem$linksExt,allowAll=TRUE)
  expect_true(cmle1$result)
  
  # store original bundle
  aem2=store.bundle.annotation(ae,b015)
  
  expect_equivalent(nrow(aem2[['items']]),736)
  expect_equivalent(nrow(aem2[['links']]),785)
  expect_equivalent(nrow(aem2[['linksExt']]),3950)
  
  
  # should be equal to original
  cm2=compare(ae$items,aem2$items,allowAll=TRUE)
  expect_true(cm2$result)
  
  # links are not changed, should be equal to original
  cml2=compare(ae$links,aem2$links,allowAll=TRUE)
  expect_true(cml2$result)
  cmle2=compare(ae$linksExt,aem2$linksExt,allowAll=TRUE)
  expect_true(cmle2$result)
  
  # TODO move segment boundaries, change links,etc...
  
  
  
})
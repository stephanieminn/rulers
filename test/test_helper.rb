$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rulers"
require "rack/test"
require "minitest/autorun"
require "./app/controllers/test_controller" # Where else can I put the test app?

$:.push(File.expand_path('../lib', __FILE__))

require 'pet-detector-server'
require 'puma'

run PetDetectorServer::V1

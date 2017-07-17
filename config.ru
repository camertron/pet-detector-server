require_relative './lib/pet-detector-server'
require 'puma'

run PetDetectorServer::V1

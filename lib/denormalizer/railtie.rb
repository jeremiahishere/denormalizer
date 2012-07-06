require 'rails'

require 'denormalizer/config'

module Denormalizer 
  class Railtie < ::Rails::Railtie
    initializer 'denormalizer' do |app|
      require "denormalizer/denormalize"
      ActiveRecord::Base.send :include, Denormalizer::Denormalize
    end
  end
end


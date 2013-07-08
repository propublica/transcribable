require 'transcribable'
require 'rails'
module Transcribable
  class Railtie < Rails::Railtie
    railtie_name :transcribable

    rake_tasks do
      load "tasks/harvester.rake"
    end
  end
end

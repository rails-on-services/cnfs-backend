# frozen_string_literal: true
#
# This approach adds a subcommand 'cnfs repo create cnfs_backend'
# The benefit is that any number of options can be declared that are specific to this type of repo

# Add a rails service configuration and optionally create a new service in a CNFS Rails repository
# To make this a registered subcommand class do this: class ServiceController < Thor
module CnfsBackend
  module Repositories
    module CreateController
      extend ActiveSupport::Concern

      included do
        # TODO: Add options that carry over to the rails plugin new command
        desc 'backend NAME', 'Create a CNFS compatible repository for services based on the Ruby on Rails Framework'
        option :database,  desc: 'Preconfigure for selected database (options: postgresql)',
                           aliases: '-D', type: :string, default: 'postgresql'
        option :test_with, desc: 'Testing framework',
                           aliases: '-t', type: :string, default: 'rspec'
        option :namespace, desc: 'How services will be named: project, repository, service',
                           type: :string, default: 'service'
        # TODO: fix this issue with url being blank
        def backend(name, url = 'h')
          invoke(name, url, 'CnfsBackend', { type: 'plugin' })
        end
      end
    end
  end
end

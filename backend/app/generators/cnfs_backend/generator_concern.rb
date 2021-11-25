# frozen_string_literal: true

# Shared methods for CnfsBackend::ServiceGenrator and CnfsBackend::RepositoryGenerator
module CnfsBackend
  module GeneratorConcern
    extend ActiveSupport::Concern

    included do
      private

      # rails_generator_path: the template that will be invoked with the call to rails -m
      # create_path: the path where the gem/service will be created; service: 'services', repo: 'lib'
      # service_name: the name of the application or plugin; service: 'iam', repo: 'core'
      # base_envs: passed in from the generator: repository or service
      def with_context(rails_generator_path, create_path, service_name, base_envs)
        source_envs = source_envs(base_envs)
        envs = base_envs.merge(source_envs).merge(service_envs)
        envs.transform_keys! { |key| "cnfs_#{key}".upcase }

        # Create the rails exec string
        rails_template_string = "-m #{internal_path.join(rails_generator_path)}"
        exec_ary = base_exec.append(rails_template_string, service_name)

        Cnfs.logger.info(envs.map { |k, v| "#{k}=#{v}" })
        Cnfs.logger.info(exec_ary.join(' '))

        inside(create_path) do
          binding.pry
          yield(envs, exec_ary)
        end
      end

      # If a source_repository is present then add the relevant attributes to the ENV hash
      def source_envs(envs)
        return {} unless options.source_repository && (source = Cnfs.repositories[options.source_repository.to_sym])

        path = Pathname.new(envs[:repo_path]).join('..', source.name).to_s
        base = { source_repo_name: source.name, source_repo_path: path }
        return base unless options.key?(:gem)

        base.merge!(gem_name: options.gem, source_gem_path: "services/#{options.gem_source}")
      end

      # Add the service attributes to the ENV hash
      # TODO: Check Cnfs.repository.test_with
      # TODO: Should require that options.type always be present?
      def service_envs
        base = options.type ? { type: options.type } : {}
        base.merge(app_dir: options.type.eql?('plugin') ? 'spec/dummy' : '.')
      end

      def base_exec
        exec_ary = options.type&.eql?('plugin') ? ['rails plugin new --full'] : ['rails new']
        # TODO: These strings should be external configuration values
        exec_ary.append('--api -G -S -J -C -T -M --skip-turbolinks --skip-active-storage')
        exec_ary.append('--dummy-path=spec/dummy') if options.type&.eql?('plugin') && options.test_with&.eql?('rspec')
        exec_ary.append('--database=postgresql')
        exec_ary
      end
    end
  end
end

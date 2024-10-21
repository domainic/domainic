# frozen_string_literal: true

require 'yaml'

require_relative 'loader'

module Domainic
  module Type
    module Load
      # @since 0.1.0
      class Registrar
        CONFIG_FILE = File.expand_path('../config/registry.yml', __dir__)

        def initialize
          load_registry!
          build_initial_index!
        end

        def all
          @registry.values.map(&:simple)
        end

        def find(alias_or_name)
          find_loader(alias_or_name)&.simple
        end

        def group(group_name)
          (@index[:groups][group_name.to_sym] || []).filter_map { |loader_name| @registry[loader_name]&.simple }
        end

        def register_alias_for_type(type_name, alias_name)
          loader = find_loader(type_name)
          return unless loader

          loader.add_alias(alias_name)
          add_alias_to_index(alias_name, loader.name)
          loader.simple
        end

        def register_group_for_type(type_name, group_name)
          loader = find_loader(type_name)
          return unless loader

          loader.add_group(group_name)
          add_group_to_index(group_name, loader.name)
          loader.simple
        end

        def register_type(**options)
          loader = Loader.new(**options)
          @registry[loader.name] = loader
          add_loader_to_index(loader)
          loader.simple
        end

        def remove_alias_for_type(type_name, alias_name)
          loader = find_loader(type_name)
          return unless loader

          loader.remove_alias(alias_name)
          remove_alias_from_index(alias_name)
          loader.simple
        end

        def remove_group_for_type(type_name, group_name)
          loader = find_loader(type_name)
          return unless loader

          loader.remove_group(group_name)
          remove_group_from_index(group_name, loader.name)
          loader.simple
        end

        def remove_type(type_name)
          loader = find_loader(type_name)
          return unless loader

          remove_loader_from_index(loader)
          @registry.delete(loader.name)
          true
        end

        private

        def add_alias_to_index(alias_name, loader_name)
          @index[:aliases][alias_name.to_sym] = loader_name
        end

        def add_group_to_index(group_name, loader_name)
          @index[:groups][group_name.to_sym] ||= []
          return if @index[:groups][group_name.to_sym].include?(loader_name)

          @index[:groups][group_name.to_sym] << loader_name
        end

        def add_loader_to_index(loader)
          loader.aliases.each { |alias_name| add_alias_to_index(alias_name, loader.name) }
          loader.groups.each { |group_name| add_group_to_index(group_name, loader.name) }
        end

        def build_initial_index!
          @index = { aliases: {}, groups: {} }
          @registry.each_value do |loader|
            add_loader_to_index(loader)
          end
        end

        def find_loader(alias_or_name)
          @registry[alias_or_name.to_sym] || @registry[@index[:aliases][alias_or_name.to_sym]]
        end

        def load_registry!
          @registry = YAML.load_file(CONFIG_FILE).each_with_object({}) do |(name, data), hash|
            hash[name.to_sym] = Loader.new(
              aliases: data['aliases'],
              constant: data['constant'],
              name: name.to_sym,
              require_path: data['require_path'],
              groups: data['groups']
            )
          end
        end

        def remove_alias_from_index(alias_name)
          @index[:aliases].delete(alias_name.to_sym)
        end

        def remove_group_from_index(group_name, loader_name)
          return unless @index[:groups][group_name.to_sym]

          @index[:groups][group_name.to_sym].delete(loader_name)
          @index[:groups].delete(group_name.to_sym) if @index[:groups][group_name.to_sym].empty?
        end

        def remove_loader_from_index(loader)
          loader.aliases.each { |alias_name| remove_alias_from_index(alias_name) }
          loader.groups.each { |group_name| remove_group_from_index(group_name, loader.name) }
        end
      end
    end
  end
end

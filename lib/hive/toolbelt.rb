#!/usr/bin/env ruby

require "thor"
require "json"
require "active_support/core_ext/string"
require_relative "toolbelt/version"

I18n.enforce_available_locales = false

module Hive
  module Toolbelt
    class CLI < Thor
      desc "init", "scaffolding a Hive app"
      def init
        config = {}
        config[:name] = ask("App Name: ")
        config[:description] = ask("Description: ")
        config[:author] = ask("Author Name: ")
        config[:contact] = ask("Author Contact: ")
        config[:repo_url] = ask("Git Repository URL: ")

        create_manifest(config)
        copy_default_icon
      end

      no_commands do
        def create_manifest config={}
          defaults = {
            version: "0.0.1",
            icon: "icon.png",
            id: id_for(config[:author], config[:name])
          }

          File.open('manifest.json', 'w') do |f|
            f.puts(JSON.pretty_generate config.clone.merge(defaults))
          end
        end

        def id_for author, name
          return "" if author.blank? || name.blank?
          "#{author.parameterize('_')}.#{name.parameterize('_')}"
        end

        include Thor::Actions
        def copy_default_icon
          source_paths << 'assets'
          copy_file File.join('images', 'icon.png'), 'icon.png'
        end
      end
    end
  end
end

Hive::Toolbelt::CLI.start

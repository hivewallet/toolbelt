require "thor"
require "json"
require "active_support"
require "active_support/core_ext/string"
require "active_support/core_ext/hash"
require "zip"

I18n.enforce_available_locales = false

module Hive
  module Toolbelt
    class CLI < Thor
      desc "init", "scaffold a Hive app"
      def init
        config = {}
        config[:name] = ask("App Name: ")
        config[:description] = ask("Description: ")
        config[:author] = ask("Author Name: ")
        config[:contact] = ask("Author Contact: ")
        config[:repoURL] = ask("Git Repository URL: ")
        config[:accessedHosts] = ask("API hosts the app needs to talk to (separated by comma. e.g. api.github.com, www.bitstamp.net): ")

        create_manifest(config)
        copy_default_icon
        copy_api_mock # for in-browser development
        create_index_html config[:name]
        create_readme config
        create_license config[:author]
        create_empty_folders
      end

      desc "package [DIR_NAME]", "package a directory into a .hiveapp bundle. DIR_NAME defaults to current working directory if not specified."
      def package dir_name='.'
        directory = File.expand_path dir_name
        directory += File::SEPARATOR unless directory.ends_with?(File::SEPARATOR)
        %w(index.html manifest.json).each do |filename|
          if Dir.glob(File.join dir_name, filename).empty?
            raise "#{filename} is required. But it's not found under #{directory}"
          end
        end

        bundle_name = bundle_name_from_manifest(File.join directory, 'manifest.json')
        Zip::File.open(bundle_name, Zip::File::CREATE) do |zipfile|
          Dir[File.join(directory, '**', '**')].each do |file|
            zipfile.add(file.sub(directory, ''), file)
          end
        end
      end

      no_commands do
        include Thor::Actions
        self.source_paths << File.join(File.dirname(__FILE__), '..', '..', '..', 'assets')

        def create_manifest config={}
          defaults = {
            version: "0.0.1",
            icon: "icon.png",
            id: id_for(config[:author], config[:name])
          }

          File.open('manifest.json', 'w') do |f|
            config[:accessedHosts] = config[:accessedHosts].split(',').map(&:strip)
            f.puts(JSON.pretty_generate config.merge(defaults))
          end
        end

        def id_for author, name
          return "" if author.blank? || name.blank?
          "#{author.parameterize('_')}.#{name.parameterize('_')}"
        end

        def copy_default_icon
          copy_file File.join('images', 'icon.png'), 'icon.png'
        end

        def copy_api_mock
          filename = File.join('javascripts', 'hiveapp-api-mock.js')
          copy_file filename, filename
        end

        def create_index_html title
          index_filename = 'index.html'
          copy_file File.join('html', index_filename), index_filename
          gsub_file index_filename, /{{title}}/, title
        end

        def create_readme config
          readme_filename = 'README.md'
          copy_file readme_filename, readme_filename
          safe_gsub_file readme_filename, /{{name}}/, config[:name]
          safe_gsub_file readme_filename, /{{description}}/, config[:description]
          safe_gsub_file readme_filename, /{{app_id}}/, id_for(config[:author], config[:name])
          safe_gsub_file readme_filename, /{{repo_url}}/, config[:repo_url]
          safe_gsub_file readme_filename, /{{project_name}}/, project_name_from(config[:repo_url])
        end

        def safe_gsub_file filename, pattern, replacement
          return if replacement.blank?

          gsub_file filename, pattern, replacement
        end

        def project_name_from repo_url
          return if repo_url.blank?

          repo_url.split('/').last.gsub(/.git$/, '')
        end

        def create_license author
          license_filename = 'LICENSE.txt'
          copy_file license_filename, license_filename
          safe_gsub_file license_filename, /{{year}}/, Time.now.year.to_s
          safe_gsub_file license_filename, /{{author}}/, author
        end

        def create_empty_folders
          %w(stylesheets images fonts).each do |dirname|
            create_file File.join(dirname, '.gitignore')
          end
        end

        def bundle_name_from_manifest manifest
          config = JSON.parse(File.read manifest).with_indifferent_access
          required = config.slice :author, :name, :version

          required.each do |k, v|
            raise "Please provide a value for `#{k}` field in manifest.json" if v.blank?
          end

          required.values.join(' ').parameterize << '.hiveapp'
        end
      end
    end
  end
end


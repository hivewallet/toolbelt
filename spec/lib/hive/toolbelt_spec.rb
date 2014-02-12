require 'spec_helper'
require 'toolbelt'
require 'fileutils'

module Hive::Toolbelt
  describe CLI do
    describe '#create_manifest' do
      let(:cli) { described_class.new }
      let(:filename) { 'manifest.json' }

      def create_manifest_json config
        default = {
          name: "",
          description: "",
          author: "",
          contact: "",
          repoURL: "",
          accessedHosts: ""
        }
        cli.create_manifest default.merge(config)
        JSON.parse File.read(filename)
      end

      it 'created manifest file has the specified config' do
        config = { foo: 1, bar: 2 }
        manifest = create_manifest_json config
        config.each do |k, v|
          expect(manifest[k.to_s]).to eq v
        end
      end

      it 'generates additional required fields' do
        config = { name: "Foo App", author: "Wei Lu" }
        manifest = create_manifest_json config

        expect(manifest["version"]).to eq("0.0.1")
        expect(manifest["icon"]).to eq("icon.png")
        expect(manifest["id"]).to eq("wei_lu.foo_app")
      end

      describe 'accessedHosts' do
        context 'when not specified' do
          it 'has `[]` as value for accessedHosts' do
            manifest = create_manifest_json({ accessedHosts: '' })

            expect(manifest["accessedHosts"]).to eq([])
          end
        end

        context 'when specified' do
          it 'populates accessedHosts with an array' do
            manifest = create_manifest_json({ accessedHosts: 'api.github.com, www.bitstamp.net' })

            expect(manifest["accessedHosts"]).to eq(['api.github.com', 'www.bitstamp.net'])
          end
        end
      end
    end

    describe '#copy_default_icon' do
      let(:cli) { described_class.new }
      let(:filename) { 'icon.png' }

      it 'provides a default icon file' do
        cli.copy_default_icon
        expect(File.exists?(filename)).to be_true
      end
    end

    describe '#copy_api_mock' do
      let(:cli) { described_class.new }

      it 'provides a mock api for in-browser development' do
        cli.copy_api_mock
        expect(File.exists?(File.join('javascripts', 'hiveapp-api-mock.js'))).to be_true
      end
    end

    describe '#create_index_html' do
      let(:cli) { described_class.new }
      let(:filename) { 'index.html' }
      let(:index) do
        cli.create_index_html 'Foo App'
        File.read(filename)
      end

      it 'creates an index.html' do
        cli.create_index_html ''
        expect(File.exists?(filename)).to be_true
      end

      it 'has app name in title' do
        expect(index).to include('<title>Foo App</title>')
      end

      it 'includes hive mock api' do
        expect(index).to include('<script src="javascripts/hiveapp-api-mock.js"></script>')
      end
    end

    describe '#create_readme' do
      let(:cli) { described_class.new }
      let(:filename) { 'README.md' }
      let(:project_name) { 'toolbelt' }
      let(:config) do
        {
          name: "Foo App",
          description: "Super awesome foo app",
          author: "Wei Lu",
          repo_url: "git@github.com:hivewallet/#{project_name}.git"
        }
      end
      let(:readme) do
        cli.create_readme config
        File.read(filename)
      end

      it 'creates a README.md' do
        cli.create_readme(config)
        expect(File.exists?(filename)).to be_true
      end

      it { expect(readme).to include(config[:name]) }
      it { expect(readme).to include(config[:description]) }
      it { expect(readme).to include("cd #{project_name}") }
      it { expect(readme).to include("ln -s ~/#{project_name}/ wei_lu.foo_app") }
      it { expect(readme).to include("git clone #{config[:repo_url]}") }
    end

    describe '#create_license' do
      let(:cli) { described_class.new }
      let(:filename) { 'LICENSE.txt' }
      let(:author) { 'Wei Lu' }
      let(:license) do
        cli.create_license author
        File.read(filename)
      end

      it 'creates a license file' do
        cli.create_license author
        expect(File.exists?(filename)).to be_true
      end

      it { expect(license).to include(author) }
      it { expect(license).to include(Time.now.year.to_s) }
    end

    describe '#create_empty_folders' do
      let(:cli) { described_class.new }


      %w(stylesheets images fonts).each do |dirname|
        it "creates #{dirname} folder" do
          cli.create_empty_folders
          expect(File.exists?(File.join(dirname, '.gitignore'))).to be_true
        end
      end
    end
  end
end

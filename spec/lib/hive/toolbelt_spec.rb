require 'spec_helper'
require 'toolbelt'

module Hive::Toolbelt
  describe CLI do
    describe '#create_manifest' do
      let(:cli) { described_class.new }
      let(:filename) { 'manifest.json' }

      it 'creates a manifest file' do
        cli.create_manifest
        expect(File.exists?(filename))
      end

      it 'created manifest file has the specified config' do
        config = { "foo" => 1, "bar" => 2 }
        cli.create_manifest config
        expect(JSON.parse File.read(filename)).to eq config
      end

      after do
        File.delete filename if File.exists?(filename)
      end
    end
  end
end

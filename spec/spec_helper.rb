APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$: << File.join(APP_ROOT, 'lib/hive')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  # clean up generated files
  generated_files = %w(manifest.json icon.png index.html README.md LICENSE.txt)
  config.before do
    generated_files.each do |filename|
      FileUtils.mv(filename, "#{filename}.tmp") if File.exists?(filename)
    end
  end
  config.after do
    generated_files.each do |filename|
      if File.exists?("#{filename}.tmp")
        FileUtils.mv( "#{filename}.tmp", filename)
      elsif File.exists?(filename)
        File.delete(filename)
      end
    end
  end
end

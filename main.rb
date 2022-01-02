require './env'
require 'deepl'
require 'json'

def help
  puts "Json translator usage:"
  puts "ruby main.rb  <input_json_file> <from_language> <result_language> [<output_file>]"
end

if ARGV.length < 3
  help
  exit
end

filename = ARGV[0]
input_lang = ARGV[1]
output_lang = ARGV[2]
output_file = ARGV[3]

###
# Read file and replace {{my var}} with xml synthax
###
file = File.read filename
file.gsub!('{{', '<x>')
file.gsub!('}}', '</x>')

###
# Load json content into hash
###
data_hash = JSON.parse file

###
# Config DeepL
###
DeepL.configure do |config|
  config.auth_key = ENV['DEEPL_API_KEY']
  config.host = ENV['DEEPL_HOST']
  config.version = ENV['DEEPL_VERSION']
end

@counter = 0
@texts = []

def translate(text, from, to)
  DeepL.translate(text, from, to, tag_handling: 'xml', ignore_tags: %w[x])
end

def recursive_logic!(item, prepare)
  if item.is_a? Hash
    iterate_hash(item, prepare)
  elsif item.is_a? Array
    prepare_array(item, prepare)
  else
    if prepare
      val = @counter
      @counter += 1
      @texts[val] = item
      val
    else
      @texts[item]
    end
  end
end

def prepare_array(array, prepare)
  array.each_with_index do |item, i|
    array[i] = recursive_logic!(item, prepare)
  end
end

def iterate_hash(hash, prepare)
  hash.each do |key, item|
    hash[key] = recursive_logic!(item, prepare)
  end
end

puts "Translatting..."
iterate_hash(data_hash, true)
@texts = translate(@texts, input_lang, output_lang)
iterate_hash(data_hash, false)

puts "Translation ended"
###
# Replace xml tags
###
translated_content = JSON.pretty_generate data_hash
translated_content.gsub!('<x>', '{{')
translated_content.gsub!('</x>', '}}')

###
# Write result to file
###
if output_file
  File.write(output_file, translated_content)
  puts "Result available inside #{output_file} file"
else
  puts translated_content
end
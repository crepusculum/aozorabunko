#!/usr/bin/env ruby
#  2012.05.16

require 'rubygems'
require 'mechanize'
require 'zipruby'

module Support
  def readfile(filename)
    result = Array.new
    open(filename) do |file|
      while line = file.gets do
        result.push(line.chomp)
      end
    end
    return result
  end

  def writefile(content, filename)
    open(filename, 'w') do |file|
      content.each do |line|
        file.puts line
      end
    end
  end

  def get_web_content(url)
    filename = File.basename(url)
    content = String.new
    agent = Mechanize.new
    begin
      content = agent.get(url).body
      return content, filename
    rescue
      puts '  maybe network has some trouble....'
      puts "      #{url}"
      exit(0)
    end
  end

  def convert_utf8(lines)
    result = Array.new
    lines.each do |line|
      line.sub!(//, '')
      result.push(Kconv.toutf8(line))
    end
    return result
  end

  def extract_zipfile(zipfile)
    filenames = Array.new
    contents = Array.new
    Zip::Archive.open(zipfile) do |zips|
      zips.num_files.times do |n|
        zips.fopen(zips.get_name(n)) do |file|
          filenames.push(file.name)
          content = convert_utf8(file.read)
          contents.push(content)
        end
      end
    end
    return contents, filenames
  end
end


#!/usr/bin/env ruby
#  2012.06.15

require File.dirname(__FILE__) + '/support'
require File.dirname(__FILE__) + '/aozorabunko_html2xhtml'
#require File.dirname(__FILE__) + '/aozorabunko_contents'

class AozoraBunko
  include Support

  DIST_TEXT = './text'
  DIST_IMAGES = './images'

  def download(url)
    prep_dist
    case url
    when /.+\.html$/ then download_html(url)
    when /.+\.zip$/ then download_zip(url)
    end
  end

  def download_html(url)
    contents, filename = get_html(url)
    path = File.dirname(url)
    image_files = image_links(contents)
    image_files.each do |image_file|
      outfile = File.basename(image_file)
      get_image(path + '/' + image_file, DIST_IMAGES + '/' + outfile)
    end
    filename = DIST_TEXT + '/' + filename.sub(/\.html/, '.xhtml')
    #generate_contents_file(contents, filename)
    xhtml = html2xhtml(contents)
    writefile(xhtml, filename)
  end

  def download_zip(url)
    contents, filenames = get_text(url)
    filenames.each_with_index do |filename, idx|
      filename = DIST_TEXT + '/' + filename
      content = contents[idx]
      #generate_contents_file(content, filename)
      writefile(content, filename)
    end
    File.delete(File.basename(url))
  end

  def prep_dist
    switch_continue = 'on'
    directories = Array.new
    [ DIST_TEXT, DIST_IMAGES ].each do |dist|
      if File.exists?(dist) then
        unless File.directory?(dist) then
          puts "  please modify '#{File.basename(dist)}' as a directory."
          switch_continue = 'off'
        end
      else
        directories.push(dist)
      end
    end
    if switch_continue == 'on' then
      directories.each do |dirname|
        Dir.mkdir(dirname)
      end
    else
      exit(0)
    end
  end

  def get_html(url)
    content, filename = get_web_content(url)
    return convert_utf8(content.split("\n")), filename
  end

  def get_image(url, outfile)
    content, filename = get_web_content(url)
    open(outfile, 'wb') do |file|
      file.puts(content)
    end
  end

  def image_links(contents)
    image_files = Array.new
    contents.each do |line|
      line.split(/</).each do |inps|
        if /img\s+src\s*=\s*\"(.+?)\".*?\/>/ =~ inps then
          image_dist = $1
          unless image_files.include?(image_dist) then
            image_files.push(image_dist)
          end
        end
      end
    end
    return image_files
  end

  def get_text(url)
    content, zipfile = get_web_content(url)
    open(zipfile, 'wb') do |file|
      file.puts(content)
    end
    contents, filenames = extract_zipfile(zipfile)
    return contents, filenames
  end
end


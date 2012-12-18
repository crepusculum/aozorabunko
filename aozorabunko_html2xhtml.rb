#!/usr/bin/env ruby
#  2012.06.17

class AozoraBunko
  HEADFILE = File.dirname(__FILE__) + '/aozorabunko_head.xhtml'

  def html2xhtml(contents)
    result = Array.new
    generate_head(contents).each do |line|
      result.push(line)
    end
    eliminate(contents).each do |line|
      result.push(line)
    end
    return result
  end

  def eliminate(contents)
    result = Array.new
    switch_body = 'off'
    contents.each do |line|
      if /<body>/ =~ line then
        switch_body = 'on'
      end
      if switch_body == 'on' then
        line.gsub!(/<a\s+href.+?>(.+?)<\/a>/, '\1')
        line.gsub!(/<script\s+.+?<\/script>/, '')
        #line.gsub!(/(<img.+?src=\").+\/(.+?\")(.+?\s*\/>)/, 'img src="../images/\2\3')
        line.gsub!(/<img.+?src=\"(\.\.\/)*([\w\d\-\/]+)\/(.+?)\s*\/>/, '<img src="../images/\3 />')
        line.gsub!(/&nbsp;/, ' ')
        line.gsub!(/<\/?rb>/, '')
        result.push(line)
      end
    end
    return result
  end

  def generate_head(contents)
    language, title = String.new
    contents.each do |line|
      if /<\/head>/ =~ line then
        break
      end
      case line
      when /lang=\"(.+?)\"/ then
        language = $1
      when /title\"\s+content=\"(.+?)\"/i then
        title = $1
      when /<title>(.+?)<\/title>/ then
        title = $1
      end
    end
    head = Array.new
    readfile(HEADFILE).each do |line|
      line.gsub!(/LANGUAGE/, language)
      line.gsub!(/TITLE/, title)
      head.push(line)
    end
    return head
  end
end


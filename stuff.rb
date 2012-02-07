require 'rubygems'
require 'nokogiri'
require 'erb'
require 'optparse'

class Stuff
  TODAY_FOCUS_TYPE = 65536.freeze
  DEFAULT_DB_PATH  = '~/Library/Application Support/Cultured Code/Things/Database.xml'.freeze

  attr_accessor :xml

  def initialize(options = {})
    @db_path        = File.expand_path options[:db_path] || DEFAULT_DB_PATH
    @template_path  = File.expand_path File.join(File.dirname(__FILE__), '/stuff.html.erb')
    @areas          = options[:areas]
    @xml            = Nokogiri::XML(open(@db_path))
    @things_by_area = {}
  end

  def run
    @areas.each do |area|
      @xml.xpath("//object[@type='TODO']/attribute[text()='#{area}']").each do |node|
        children_node = node.parent.xpath("relationship[@name='children']").first

        todays_todos = get_todays_todos children_node['idrefs'].split

        @things_by_area[area] = todays_todos if todays_todos.size > 0
      end
    end

    puts ERB.new(open(@template_path).read).result(binding)
  end

  def get_todays_todos(idrefs)
    todos = []

    idrefs.each do |idref|
      attribute = @xml.xpath("//object[@type='TODO'][@id='#{idref}']/attribute[@name='focustype'][text()='#{TODAY_FOCUS_TYPE}']").first

      next if !attribute

      parent_node      = attribute.parent
      title_node       = parent_node.xpath("attribute[@name='title']").first
      completed_node   = parent_node.xpath("attribute[@name='datecompleted']").first
      description_node = parent_node.xpath("attribute[@name='content']").first

      todos << {
        :title       => title_node.text,
        :completed   => !completed_node.nil?,
        :description => description_node ? description_node.text.gsub('\u3c00note xml:space="preserve"\u3e00', '').gsub('\u3c00/note\u3e00', '').strip : nil
      }
    end

    todos
  end
end

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: stuff.rb Area1 Area2 Area3 [options]"

  opts.on("-p", "--db-path [PATH]", String, "Path to DB (default: #{Stuff::DEFAULT_DB_PATH})") do |path|
    options[:db_path] = path
  end
end

parser.parse!

options = { areas: ARGV }.merge(options)

options.empty? ? puts(parser.help) : Stuff.new(options).run

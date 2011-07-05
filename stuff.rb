require 'rubygems'
require 'nokogiri'
require 'erb'

class Stuff
  TODAY_FOCUS_TYPE         = 65536.freeze
  DEFAULT_PATH_TO_DATABASE = '~/Library/Application Support/Cultured Code/Things/Database.xml'.freeze

  def initialize(options = {})
    @path_to_database = File.expand_path options[:path_to_database] || DEFAULT_PATH_TO_DATABASE
    @path_to_template = File.expand_path File.join(File.dirname(__FILE__), '/stuff.html.erb')
    @areas            = options[:areas]
    @xml              = Nokogiri::XML(open(@path_to_database))
    @things_by_area   = {}
  end

  def run
    @areas.each do |area|
      @xml.xpath("//object[@type='TODO']/attribute[text()='#{area}']").each do |node|
        children_node = node.parent.xpath("relationship[@name='children']").first

        todays_todos = get_todays_todos children_node['idrefs'].split

        @things_by_area[area] = todays_todos if todays_todos.size > 0
      end
    end

    puts ERB.new(open(@path_to_template).read).result(binding)
  end

  def get_todays_todos(idrefs)
    todos = []

    idrefs.each do |idref|
      attribute = @xml.xpath("//object[@type='TODO'][@id='#{idref}']/attribute[@name='focustype'][text()='#{TODAY_FOCUS_TYPE}']").first

      next if !attribute

      todos << {
        :title     => attribute.parent.xpath("attribute[@name='title']").first.text,
        :completed => !attribute.parent.xpath("attribute[@name='datecompleted']").first.nil?
      }
    end

    todos
  end
end

Stuff.new(:areas => ARGV).run

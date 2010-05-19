require 'rubygems'
require 'yaml'
class String
def red; colorize(self, "\e[1m\e[31m"); end
def green; colorize(self, "\e[1m\e[32m"); end
def dark_green; colorize(self, "\e[32m"); end
def yellow; colorize(self, "\e[1m\e[33m"); end
def blue; colorize(self, "\e[1m\e[34m"); end
def dark_blue; colorize(self, "\e[34m"); end
def pur; colorize(self, "\e[1m\e[35m"); end
def colorize(text, color_code) "#{color_code}#{text}\e[0m" end
def clean; self.gsub(/\n|\t|\r/, ' ').gsub(/[\(\)\/_-]/, ' ').squeeze(' ').strip end
def title_from_path
  self.gsub(/\/content/, '').split('/').last.split('.').first.upcase_split.join(' ')
end
def upcase_split
  arr = []
  innum = false
  word = ""
  self.each_char do |char|
    if char =~ /[A-Z]/
      #save prev word into buffer
      arr << word unless word == ""
      word = ""
      word << char #start new word
      innum = false
    elsif char =~ /[0-9]/
      if innum
        word += char 
      else
        innum = true
        arr << word
        word = ""
        word << char #start new word
      end
    else 
      word += char 
    end
  end
  arr << word
end
end
module MakeMoney
  # :stopdoc:
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  V = YAML.load_file(File.join(File.dirname(__FILE__), %w[VERSION.yml]))
  VERSION = "#{V[:major]}.#{V[:minor]}.#{V[:patch]}" 
  # :startdoc:
  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end
  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end
  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end
  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end
  def self.display_version
    "\n#{'MakeMoney'.green} version #{MakeMoney.version.pur}\n\n"
  end
  # Write siple console log
  def self.log(txt)
    puts "#{txt}"
  end
  #write the content to file destination
  def self.write(content, destination)
    file = File.open destination, File::RDWR|File::TRUNC|File::CREAT, 0664
    file.puts content
    file.close
  end
  def self.write_program(content, destination)
final = <<-RAW
[
#{content}
]
RAW
    MakeMoney.write(final, destination)
  end
  def self.write_stage(content, destination)
final = <<-RAW
{
#{content}
}
RAW
    MakeMoney.write(final, destination)
  end
  #
  # Error class
  #
  class Error < StandardError
    def initialize(message = nil)
      super(message)
    end      
  end
end
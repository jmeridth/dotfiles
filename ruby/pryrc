Pry.config.editor = 'vim'

Pry.config.prompt = proc do |obj, _|
  prompt = ''
  prompt << "#{Rails.version}@" if defined?(Rails)
  prompt << "#{RUBY_VERSION}"
  "#{prompt} (#{obj})> "
end

Pry.config.exception_handler = proc do |output, exception, _|
  output.puts "\e[31m#{exception.class}: #{exception.message}"
  output.puts "from #{exception.backtrace.first}\e[0m"
end

# if defined?(PryByebug)
if Pry.commands.collect(&:first).include?('continue')
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end

if defined?(Rails)
  begin
    require 'rails/console/app'
    require 'rails/console/helpers'

    TOPLEVEL_BINDING.eval('self').extend ::Rails::ConsoleMethods
  rescue
    require 'console_app'
    require 'console_with_helpers'
  end
end

# Hit Enter to repeat last command
Pry::Commands.command(/^$/, 'repeat last command') do
  _pry_.run_command Pry.history.to_a.last
end

begin
  require 'awesome_print'
  Pry.config.print = proc do |output, value|
    Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)
  end
rescue
  warn '=> Unable to load awesome_print'
end

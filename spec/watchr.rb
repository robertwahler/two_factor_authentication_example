# Watchr: Autotest like functionality
#
# Run me with:
#
#   $ watchr spec/watchr.rb

require 'term/ansicolor'

$c = Term::ANSIColor

def getch
  state = `stty -g`
  begin
    `stty raw -echo cbreak`
    $stdin.getc
  ensure
    `stty #{state}`
  end
end

# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def all_spec_files
  Dir['spec/models/*_spec.rb'] + Dir['spec/controllers/*_spec.rb'] + Dir['spec/framework/*_spec.rb']
end

def run(cmd)

  pid = fork do
    puts "\n"
    print $c.cyan, cmd, $c.clear, "\n"
    exec(cmd)
  end
  Signal.trap('INT') do
    puts "sending KILL to pid: #{pid}"
    Process.kill("KILL", pid)
  end
  Process.waitpid(pid)

  prompt
end

def run_all
  run_all_specs
end

def run_default_spec
  cmd = "rspec"
  run(cmd)
end

def run_all_specs
  cmd = "rspec #{all_spec_files.join(' ')}"
  p cmd
  run(cmd)
end

def run_spec(spec)
  cmd = "rspec #{spec}"
  $last_spec = spec
  run(cmd)
end

def run_last_spec
  run_spec($last_spec) if $last_spec
end

def prompt
  puts "Ctrl-\\ for menu, Ctrl-C to quit"
end

# init
prompt
# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch( '^spec.*/controllers/.*_spec\.rb'   )   { |m| run_spec(m[0]) }
watch( '^spec.*/models/.*_spec\.rb'   )   { |m| run_spec(m[0]) }
watch( '^spec.*/framework/.*_spec\.rb'   )   { |m| run_spec(m[0]) }

watch( '^spec/factories/(.*)\.rb'   )   { |m| run_spec("spec/controllers/%s_controller_spec.rb" % m[1]) }
watch( '^app/models/(.*)\.rb'   )   { |m| run_spec("spec/models/%s_spec.rb" % m[1]) }
watch( '^app/controllers/(.*)\.rb'   )   { |m| run_spec("spec/controllers/%s_spec.rb" % m[1]) }
watch( '^app/views/(.*)/.*'   )   { |m| run_spec("spec/controllers/%s_controller_spec.rb" % m[1]) }
watch( '^app/helpers/(.*)/.*'   )   { |m| run_spec("spec/controllers/%s_controller_spec.rb" % m[1]) }

watch( '^spec/spec_helper\.rb' )   { run_all_specs }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------

# Ctrl-\
Signal.trap('QUIT') do

  puts "\n\nMENU: a = all , s = specs, q = quit\n\n"
  c = getch
  puts c.chr
  if c.chr == "a"
    run_all
  elsif c.chr == "s"
    run_all_specs
  elsif c.chr == "q"
    abort("exiting\n")
  end

end

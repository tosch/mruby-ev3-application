ev3_gem_path = File.expand_path(File.join('..', 'mruby-ev3'), __dir__)

# Define cross build settings for MINDSTORMS EV3
MRuby::CrossBuild.new('ev3') do |conf|
  toolchain :gcc

  # C compiler settings
  conf.cc.command = 'arm-linux-gnueabi-gcc'

  # Linker settings
  conf.linker.command = 'arm-linux-gnueabi-gcc'
  conf.linker.flags << %w(-static)
  conf.linker.libraries << []

  # Archiver settigns
  conf.archiver.command = 'arm-linux-gnueabi-ar'

  conf.build_mrbtest_lib_only

  # Gemset config
  # Default gembox
  conf.gembox 'default'

  # Other mrbgems
  conf.gem mgem: 'mruby-logger'
  conf.gem mgem: 'mruby-simplehttpserver'
  conf.gem github: 'mattn/mruby-json'
  conf.gem path: ev3_gem_path
end

MRuby::CrossBuild.new('ev3-debug') do |conf|
  toolchain :gcc

  # C compiler settings
  conf.cc.defines = %w(MRB_ENABLE_DEBUG_HOOK)
  conf.cc.command = 'arm-linux-gnueabi-gcc'

  # Linker settings
  conf.linker.command = 'arm-linux-gnueabi-gcc'
  conf.linker.flags << %w(-static)
  conf.linker.libraries << []

  # Archiver settings
  conf.archiver.command = 'arm-linux-gnueabi-ar'

  enable_debug

  # Gemset config
  conf.gembox 'default'

  # Generate mruby debugger command (require mruby-eval)
  conf.gem :core => "mruby-bin-debugger"

  # Other mrbgems
  conf.gem mgem: 'mruby-logger'
  conf.gem mgem: 'mruby-simplehttpserver'
  conf.gem github: 'mattn/mruby-json'
  conf.gem path: ev3_gem_path
end

MRuby::Build.new('test') do |conf|
  toolchain :gcc

  conf.enable_test

  conf.gembox 'default'
  conf.gem path: ev3_gem_path
  conf.gem :github => 'iij/mruby-mtest', :branch => 'master'
end

MRuby::Build.new do |conf|
  # load specific toolchain settings
  toolchain :gcc

  # Use mrbgems
  # conf.gem 'examples/mrbgems/ruby_extension_example'
  # conf.gem 'examples/mrbgems/c_extension_example' do |g|
  #   g.cc.flags << '-g' # append cflags in this gem
  # end
  # conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
  # conf.gem :github => 'masuidrive/mrbgems-example', :branch => 'master'
  # conf.gem :git => 'git@github.com:masuidrive/mrbgems-example.git', :branch => 'master', :options => '-v'

  # include the default GEMs
  conf.gembox 'default'
  conf.gem path: ev3_gem_path

  # C compiler settings
  # conf.cc do |cc|
  #   cc.command = ENV['CC'] || 'gcc'
  #   cc.flags = [ENV['CFLAGS'] || %w()]
  #   cc.include_paths = ["#{root}/include"]
  #   cc.defines = %w(DISABLE_GEMS)
  #   cc.option_include_path = '-I%s'
  #   cc.option_define = '-D%s'
  #   cc.compile_options = "%{flags} -MMD -o %{outfile} -c %{infile}"
  # end

  # mrbc settings
  # conf.mrbc do |mrbc|
  #   mrbc.compile_options = "-g -B%{funcname} -o-" # The -g option is required for line numbers
  # end

  # Linker settings
  # conf.linker do |linker|
  #   linker.command = ENV['LD'] || 'gcc'
  #   linker.flags = [ENV['LDFLAGS'] || []]
  #   linker.flags_before_libraries = []
  #   linker.libraries = %w()
  #   linker.flags_after_libraries = []
  #   linker.library_paths = []
  #   linker.option_library = '-l%s'
  #   linker.option_library_path = '-L%s'
  #   linker.link_options = "%{flags} -o %{outfile} %{objs} %{libs}"
  # end

  # Archiver settings
  # conf.archiver do |archiver|
  #   archiver.command = ENV['AR'] || 'ar'
  #   archiver.archive_options = 'rs %{outfile} %{objs}'
  # end

  # Parser generator settings
  # conf.yacc do |yacc|
  #   yacc.command = ENV['YACC'] || 'bison'
  #   yacc.compile_options = '-o %{outfile} %{infile}'
  # end

  # gperf settings
  # conf.gperf do |gperf|
  #   gperf.command = 'gperf'
  #   gperf.compile_options = '-L ANSI-C -C -p -j1 -i 1 -g -o -t -N mrb_reserved_word -k"1,3,$" %{infile} > %{outfile}'
  # end

  # file extensions
  # conf.exts do |exts|
  #   exts.object = '.o'
  #   exts.executable = '' # '.exe' if Windows
  #   exts.library = '.a'
  # end

  # file separetor
  # conf.file_separator = '/'
end


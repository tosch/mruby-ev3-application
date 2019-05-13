MRuby::Gem::Specification.new('mruby-ev3') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Torsten Schönebaum'
  spec.summary = 'mrbgem for controlling LEGO Mindstorms EV3 robots running ev3dev'

  spec.add_dependency('mruby-array-ext', core: 'mruby-array-ext')
  spec.add_dependency('mruby-class-ext', core: 'mruby-class-ext')
  spec.add_dependency('mruby-compar-ext', core: 'mruby-compar-ext')
  spec.add_dependency('mruby-enum-ext', core: 'mruby-enum-ext')
  spec.add_dependency('mruby-error', core: 'mruby-error')
  spec.add_dependency('mruby-fiber', core: 'mruby-fiber')
  spec.add_dependency('mruby-hash-ext', core: 'mruby-hash-ext')
  spec.add_dependency('mruby-io', core: 'mruby-io')
  spec.add_dependency('mruby-kernel-ext', core: 'mruby-kernel-ext')
  spec.add_dependency('mruby-math', core: 'mruby-math')
  spec.add_dependency('mruby-metaprog', core: 'mruby-metaprog')
  spec.add_dependency('mruby-method', core: 'mruby-method')
  spec.add_dependency('mruby-numeric-ext', core: 'mruby-numeric-ext')
  spec.add_dependency('mruby-object-ext', core: 'mruby-object-ext')
  spec.add_dependency('mruby-pack', core: 'mruby-pack')
  spec.add_dependency('mruby-print', core: 'mruby-print')
  spec.add_dependency('mruby-sleep', core: 'mruby-sleep')
  spec.add_dependency('mruby-string-ext', core: 'mruby-string-ext')
  spec.add_dependency('mruby-symbol-ext', core: 'mruby-symbol-ext')
  spec.add_dependency('mruby-dir', github: 'iij/mruby-dir')
  spec.add_dependency('mruby-errno', github: 'iij/mruby-errno')
  spec.add_dependency('mruby-pure-regexp', github: 'h2so5/mruby-pure-regexp')
  spec.add_dependency('mruby-rational', github: 'dyama/mruby-rational')
end

require 'sprout'
sprout 'as3'

project_model :model do |m|
  m.project_name            = 'Reflection'
  m.language                = 'as3'
  m.background_color        = '#FFFFFF'
  m.width                   = 970
  m.height                  = 550
end

desc 'Compile run the test harness'
unit :test

desc 'Create documentation'
document :doc

desc 'Compile a SWC file'
swc :swc do |t|
  t.input = 'p2.reflect.Reflection'
end

# set up the default rake task
task :default => :debug

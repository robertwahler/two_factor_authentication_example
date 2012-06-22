# starts up/reloads the spork server
guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('spec/framework_spec_helper.rb') { :rspec }
  watch('spec/shoulda_spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
end

group :specs do
  guard 'rspec',
        :all_after_pass => false,
        :all_on_start => false,
        :bundler => false,
        :cli => '--drb --color --format nested',
        :version => 2 do

    watch('spec/spec_helper.rb')                        { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }

    watch(%r{^spec/.+_spec\.rb})
    watch(%r{^app/(.+)\.rb})                            { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb})   { |m| [ "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb" ] }
    watch(%r{^app/views/(.+)/})                         { |m| "spec/controllers/#{m[1]}_controller_spec.rb" }

    watch(%r{^spec/factories/(.*)\.rb} )                { |m| "spec/controllers/%s_controller_spec.rb" % m[1] }
    watch(%r{^app/helpers/(.*)/.*} )                    { |m| "spec/controllers/%s_controller_spec.rb" % m[1] }
  end
end

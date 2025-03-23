namespace :db do
  namespace :fixtures do
    desc "Load fixtures in a specific order"
    task load_ordered: :environment do
      fixtures = %w[users collections admins events
                  likes pages profiles profiles_users submissions]
      fixtures.each do |fixture|
        ENV["FIXTURES"] = fixture
        Rake::Task["db:fixtures:load"].invoke
        Rake::Task["db:fixtures:load"].reenable
      end
    end
  end
end

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

every :day, at: '2:16pm', timezone: 'Pacific Time (US & Canada)' do
	command "/home/ubuntu/.rbenv/shims/ruby /home/ubuntu/platonic-rails/app/bin/rails runner -e production 'Api::V1::MeetsController.create_meetings'"
end

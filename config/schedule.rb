# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, 'log/schedule.log'

#every :day, at: '1pm', timezone: 'Pacific Time (US & Canada)' do
every 1.minute do
	runner "Api::V1::MeetsController.create_meetings"
end

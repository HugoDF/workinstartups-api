require_relative 'api'

a = WISAPI.new
# a.set_format('id title')
a.set_from(Date.today - 2)
puts a.get_latest.join("\n")
# a.set_format("title category description")
print a.get_job "42063"

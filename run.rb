require './api.rb'

a = API.new(1, 20)
a.set_from(Date.today - 10)
p a.get
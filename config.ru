require 'json'

map '/time.json' do
  run lambda { |env| 
    [200, {"Content-Type" => "application/json"}, [{time: Time.now.to_f, bpm: ENV['bpm']}.to_json]]
  }
end

use Rack::Static, :urls => ['/'], :index => 'index.html'

run lambda { |*| }

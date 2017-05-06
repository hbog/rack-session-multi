require_relative 'session_multi'

use SessionMulti, factor: 2,
    expire_after: 10,
    eternal_client: '127.0.0.1'

TstApp = lambda do |env|
    session = env['rack.session']
    session[:id] = Time.now unless session[:id]
    response = Rack::Response.new [ 'session ', session[:id].to_s, "\n" ]
    response.finish
end

run TstApp

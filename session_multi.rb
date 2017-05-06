require 'rack'

# Rack::Session's session lifetime is set during initialization and is
# fixed to the same value for every client.
# This middleware adds the ability to specify a longer session lifetime
# for requests originating from a given client ip.
# It is configured by specifying :factor (as a multiplier for :ecpire_after) and
# :eternal_client (as the ip of the client that needs long lasting sessions).
# A caookie based session is used for maximum persistence
class SessionMulti

    def initialize app, options = {}
        factor = options.delete(:factor) || 1000
        eternal_client = options.delete(:eternal_client)
        expire_after = options.delete(:expire_after) || 14400
        # This closure is injected in the stack with rack::session::cookie
        # It sets an expires key on the session and destroys expired sessions
        expire = lambda do | env|
            req = Rack::Request.new(env)
            session = req.session
            now = Time.now.to_i

            # Destroy if expired or if no expiry set
            session.destroy unless session[:_expires] && session[:_expires] > now

            # Make session expiring if not yet the case
            unless session[:_expires]
                expiry = req.ip == eternal_client ? factor * expire_after : expire_after
                session[:_expires] = now + expiry
            end

            # Call the next app on the stack
            app.call env
        end
        @app = Rack::Session::Cookie.new expire, options
    end

    def call env
        @app.call env
    end
end

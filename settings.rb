# The following are exposed globally via settings.key_name.
set :raise_errors,    false
set :show_exceptions, false

set :sessions,        true 
set :session_secret,  $sc[:session_secret]

set :my_key,          'my_val' # settings.my_key == 'my_val

# The following are exposed globally via $varname.
$app_name   = 'pickeez'
$prod       = settings.production? #env is set via RACK_ENV=production in prod 
$root_url   = 'http://localhost:9292'



Installation

Brimir is a rather simple Ruby on Rails application. The only difficulty in setting things up is how to get incoming email to work. See the next section for details.

Any Rails application needs a web server with Ruby support first. We use Phusion Passenger (mod_rails) ourselves, but you can also use Thin, Puma or Unicorn. Phusion Passenger can be installed for Nginx or Apache, you can chose wichever you like best. The installation differs depending on your distribution, so have a look at their Nginx installation manual or their Apache installation manual.

After setting up a webserver, you have to create a database for Brimir and modify the config file in config/database.yml to reflect the details. Set your details under the production section. We advise to use adapter: postgresql or adapter: mysql2 for production usage, because those are the only two adapters and database servers we test. If you plan to use MySQL, make sure you use utf8 as your charset and collation.

Next up: configuring your outgoing email address and url. This can be set in config/environments/production.rb by adding the following lines before the keyword end:

config.action_mailer.default_options = { from: 'brimir@yoururl.com' }

config.action_mailer.default_url_options = { host: 'brimir.yoururl.com' }
Now install the required gems by running the following command if you want PostgreSQL support:

bundle install --without sqlite mysql development test --deployment
Run the following command to install gems if you want MySQL support:

bundle install --without sqlite postgresql development test --deployment
Generate a secret_key_base in the secrets.yml file:

LINUX: sed -i "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml
MAC: sed -i "" "s/<%= ENV\[\"SECRET_KEY_BASE\"\] %>/`bin/rake secret`/g" config/secrets.yml
Next, load the database schema and precompile assets:

bin/rake db:schema:load RAILS_ENV=production
bin/rake assets:precompile RAILS_ENV=production
If you want to use LDAP, configure config/ldap.yml accordingly, then change the auth strategy in your application config in file config/application.rb:

config.devise_authentication_strategy = :ldap_authenticatable
(Optional for LDAP) Last thing left to do before logging in is making a user and adding some statuses. You can do this by running:

bin/rails console production
u = User.new({ email: 'your@email.address', password: 'somepassword', password_confirmation: 'somepassword' }); u.agent = true; u.save!

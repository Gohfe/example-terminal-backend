require 'sinatra'
require 'stripe'
require 'dotenv'
require 'json'

Dotenv.load
Stripe.api_key = ENV['STRIPE_TEST_SECRET_KEY']

def log_info(message)
  puts "\n" + message + "\n\n"
  return message
end

get '/' do
  status 200
  return log_info("Great, your backend is set up. Now you can configure the Stripe Terminal example apps to point here.")
end

# This endpoint is used by the example apps to retrieve a connection token
# from Stripe.
# iOS           https://stripe.com/docs/terminal/ios#connection-token
# JavaScript    https://stripe.com/docs/terminal/js#connection-token
# Android       Coming Soon
post '/connection_token' do
  begin
    token = Stripe::Terminal::ConnectionToken.create
  rescue Stripe::StripeError => e
    status 402
    return log_info("Error creating connection token: #{e.message}")
  end

  content_type :json
  status 200
  token.to_json
end

# This endpoint is used by the JavaScript example app to create a PaymentIntent.
# The iOS and Android example apps create the PaymentIntent client-side
# using the SDK.
# https://stripe.com/docs/terminal/js/payment#create
post '/create_intent' do
  begin
    intent = Stripe::PaymentIntent.create(
      :allowed_source_types => ['card_present'],
      :capture_method => 'manual',
      :amount => params[:amount],
      :currency => params[:currency] || 'usd',
      :description => params[:description] || 'Example PaymentIntent',
    )
  rescue Stripe::StripeError => e
    status 402
    return log_info("Error creating payment intent: #{e.message}")
  end

  log_info("Payment Intent successfully created")
  status 200
  return {:intent => intent.id, :secret => intent.client_secret}.to_json
end

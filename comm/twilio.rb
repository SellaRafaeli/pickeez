require 'twilio-ruby' 
 
# put your own credentials here 
account_sid = 'ACfbbb449751b5c36f48fb0aa1f2065774' 
auth_token = settings.twilio_auth_token
 
# set up a client to talk to the Twilio REST API 
TWILIO_CLIENT ||= Twilio::REST::Client.new account_sid, auth_token 

def send_sms(to, body = nil)
  body ||= "test msg"
  TWILIO_CLIENT.account.messages.create({
    from: '+18442762975',  
    to: "+#{to}",
    body: body    
  })
end

#send_sms('972522934321', 'some text')
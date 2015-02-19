$users = $mongo.collection('users')

SETTABLE_USER_FIELDS = [:name, :desc, :img, :phone, 
                :email, :fb_page, :website, :updated_at,
                :phone_verification_code, :verified_phone, :pic_url
              ]

module Users
  extend self

  def create(params)
    $users.add(params.merge({token: SecureRandom.urlsafe_base64+SecureRandom.urlsafe_base64}))  
  end

  def get(id)
    $users.get(id)
  end

  def basic_data(field, val)
    $users.project({field.to_s => val}, ['fb_id','name','pic_url'])
  end

  def get_or_create_by_fb_id(fb_id, fb_data = {})
    fb_id = fb_id.to_s
    pic_url = "http://graph.facebook.com/#{fb_id}/picture"
    $users.get({fb_id: fb_id}) || create({fb_id: fb_id, pic_url: pic_url, fb_data: fb_data})
  end 

  def get_by_email(email)
    $users.find_one({email: email})
  end

  def update(params)    
    fields = params.just(SETTABLE_USER_FIELDS)
    $users.update_id(params[:id], fields)    
  end

  def create_test_users
    (0..10).each {|i|
      i = i.to_s
      $users.update({_id: i}, {"$set" => {fb_id: i, token: i, name: "test_user_#{i}", created_at: Time.now}}, {upsert: true})
    }
  end

end

get '/users' do
  {num: $users.count, users: $users.all}
end

post '/set_phone' do
  res = Users.update({phone: params[:phone], phone_verification_code: rand(1000..9000), id: cuid}) 
  #TODO: send actual SMS
  Users.get(cuid) || 404
end

post '/resend_code_sms' do
  {msg: 'not yet implemented.'}
end

post '/confirm_phone' do
  if cu['phone_verification_code'].to_i == params['code'].to_i 
    #TODO: send actual SMS 
    Users.update({id: cuid, verified_phone: cu['phone']});
    {ok: true}
  else 
    {err: 'wrong code'}
  end
end

get "/fb" do
  redirect "https://graph.facebook.com/oauth/authorize?client_id=#{@client_id}&redirect_uri=#{$root_url}/fb_enter_browser"
end

get '/me' do
  current_user
end

#browser endpoint
get "/fb_enter_browser" do
  code = params[:code]
  endpoint = "https://graph.facebook.com/oauth/access_token?client_id=#{@client_id}&redirect_uri=#{$root_url}/fb_enter_browser&client_secret=#{@client_secret}&code=#{code}"
  response = HTTPClient.new.get endpoint
  access_token = CGI.parse(response.body)["access_token"][0]
  
  #4. use auth-token to get user data
  endpoint = "https://graph.facebook.com/me?access_token=#{access_token}"
  response = HTTPClient.new.get endpoint
  fb_data = JSON.parse(response.body)
  
  user = Users.get_or_create_by_fb_id(fb_data['id'], fb_data)
  {token: user['token'], user: user}
end

get '/fb_enter' do
  code = params[:code]
  endpoint = "https://graph.facebook.com/me?access_token=#{code}"
  response = HTTPClient.new.get endpoint
  fb_data = JSON.parse(response.body)
  fb_data['code'] = code
  user = Users.get_or_create_by_fb_id(fb_data['id'], fb_data)
  {token: user['token']}
end

post '/delete_me' do
  if params['sure'] == 'yes' 
    $albums.remove({owner_id: cuid})
    $users.remove({_id: cuid}, {justOne: true})
    {msg: 'removed'}
  else 
    {msg: 'please send "sure" parameter as "yes" if you are sure.'}
  end
end

post '/set_pic_url' do
  url = params['pic_url']
  url ? $users.update_id(cuid, {pic_url: url}) : halt(404, 'no pic_url provided')
end
#Users.create_test_users


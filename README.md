Welcome to pickeez backend for managing Pickeez data. 

Important routes, in expected chronological order of usage (HTTP GET unless otherwise specified):

> '/fb' - will redirect you (in browser) to approve app (temporary app. ID: 311069229089167).

> '/fb_enter?code=abcd...' 
  - hit this route with the code after app-aproval on FB
  - will create user if non-existent, and return pickeez token. Send this token in any further request.
  - this route is redirected to after hitting route '/fb' in browser. 

> '/me' - will return the user pickeez identifies as sending the request. Send with pickeez token, as in '/me?token=wqQjsY0j4-3biVLi8C0EYwCa18RFzzBrNqBVduipoo-w'

> POST '/albums/create' - creates an album, returns created album_id.

> POST '/albums/123?name=donkey' - updates album 123 with params sent, such as 'name'. (Send post params in body request, of course.) 

  > to delete album, supply parameter 'deleted=true' to this call. 

> '/albums/mine' - returns list of albums belonging to requesting user. 

> POST '/photos/' - add a photo. Required params are 's3_path' and a valid album_id.

> '/albums/123' - gets album with its photos, grouped by users.  

> POST '/set_phone?phone=4567' - sets phone number of requesting user to 4567. (Does not yet send SMS.)

> POST '/resend_code_sms' - resends the code as an sms. (Does not yet send SMS.)

> POST '/confirm_phone?code=3456' - marks phone number as confirmed if code is correct.    

> POST "phones[]=555&phones[]=777" '/albums/123/invite_phones' - invites phones 555 and 777 to album 123. Adding parameter "remove=true" *removes* each of these phones instead of adding them (which has the effect of deleting a user from album). If added later, their photos will be re-added. 

> POST '/albums/123/delete' - deletes that album. (Actually only marks it as deleted so it won't be retrieved when calling list of albums). 

TBD:

> Send SMS with code upon entering phone and when requesting resend. 
> Send SMS/push notif when inviting user to album

> log out
> delete user? 
> change profile pic 
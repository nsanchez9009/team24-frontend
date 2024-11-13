
String? sessionToken ="";

bool setToken(String token){
  sessionToken = token;
  return true;

}

bool clearToken(){
  sessionToken = null;
  return true;
   
}

String? getToken(){
  if(sessionToken == null){
    return null;
  }
  else{
    return sessionToken;
  }
}
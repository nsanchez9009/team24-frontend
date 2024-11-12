
String? sessionToken ="";

bool setToken(String token){
  sessionToken = token;
  return true;

}

void clearToken(){
  sessionToken = null;
   
}

String? getToken(){
  if(sessionToken == null){
    return null;
  }
  else{
    return sessionToken;
  }
}
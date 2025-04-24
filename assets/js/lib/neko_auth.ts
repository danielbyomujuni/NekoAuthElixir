import { Navigate } from "react-router";


function login() {
    const params:URLSearchParams = new URLSearchParams();
    params.set("client_id", "1");
    params.set("redirect_uri", "http://localhost:4050/api/v1/portal/callback");
    params.set("scope", "openid profile email");
    params.set("response_type", "code");
    params.set("response_mode", "form_post");
    params.set("state", "lwbr5vfrrc"); //Generate a random state string
    params.set("nonce", "fyfl3y81p7d"); //Generate a random nounce string

    window.location.href = ("/api/v1/oauth/authorize?" + params.toString());
}




export {
    login
}
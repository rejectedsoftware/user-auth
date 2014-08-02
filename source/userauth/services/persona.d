module userauth.services.persona;

import userauth.userauth;

import vibe.core.log;
import vibe.http.client;
import vibe.stream.memory;
import vibe.templ.diet;


class PersonaAuthService : UserAuthService {
	string generateAuthMixin(HTTPServerRequest req, string path_prefix)
	{
		logDebug("logged in: %s %s", req.session.id !is null, req.cookies);
		auto dst = new MemoryOutputStream;
		string authUserEmail;
		if( req.session ) authUserEmail = req.session["email"];
		parseDietFileCompat!("userauth-persona-auth-mixin.dt",
			string, "path_prefix",
			string, "authUserEmail")(dst, path_prefix, authUserEmail);
		return cast(string)dst.data();
	}

	void registerRoutes(URLRouter router, string path_prefix)
	{
		// NOTE: need to be at root directory because the cookie has to be available
		// on all pages
		router.post("/persona-login", &login);
		router.post("/persona-logout", &logout);
	}

	private void login(HTTPServerRequest req, HTTPServerResponse res)
	{
		enforceHTTP("assertion" in req.form, HTTPStatus.BadRequest, "'assertion' field is missing.");

		auto cres = requestHTTP("https://verifier.login.persona.org/verify", (scope creq){
				creq.method = HTTPMethod.POST;
				creq.writeJsonBody(["assertion": req.form["assertion"], "audience": "http://localhost:8080/"]);
			});

		enforceHTTP(cres.statusCode == HTTPStatus.OK, HTTPStatus.Unauthorized, "Auth assertion could not be validated.");

		auto jres = cres.readJson();
		enforceHTTP(jres.status.get!string == "okay", HTTPStatus.Unauthorized, "Auth assertion is invalid.");

		Session session = req.session;
		if( !session ) session = res.startSession();
		session["email"] = jres.email.get!string;
		res.writeJsonBody(jres);
	}

	private void logout(HTTPServerRequest req, HTTPServerResponse res)
	{
		if( req.session ) res.terminateSession();
		res.writeJsonBody(["message": "Successfully logged out."]);
	}
}
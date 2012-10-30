module userauth.services.persona;

import userauth.userauth;

import vibe.core.log;
import vibe.http.client;
import vibe.stream.memory;
import vibe.templ.diet;


class PersonaAuthService : UserAuthService {
	string generateAuthMixin(HttpServerRequest req, string path_prefix)
	{
		logDebug("logged in: %s %s", req.session !is null, req.cookies);
		auto dst = new MemoryOutputStream;
		string authUserEmail;
		if( req.session ) authUserEmail = req.session["email"];
		parseDietFileCompat!("userauth-persona-auth-mixin.dt",
			string, "path_prefix",
			string, "authUserEmail")(dst, Variant(path_prefix), Variant(authUserEmail));
		return cast(string)dst.data();
	}

	void registerRoutes(UrlRouter router, string path_prefix)
	{
		router.post(path_prefix~"persona-login", &login);
		router.post(path_prefix~"persona-logout", &logout);
	}

	private void login(HttpServerRequest req, HttpServerResponse res)
	{
		enforceHttp("assertion" in req.form, HttpStatus.BadRequest, "'assertion' field is missing.");

		auto cres = requestHttp("https://verifier.login.persona.org/verify", (creq){
				creq.method = HttpMethod.POST;
				creq.writeJsonBody(["assertion": req.form["assertion"], "audience": "http://localhost:8080/"]);
			});

		enforceHttp(cres.statusCode == HttpStatus.OK, HttpStatus.Unauthorized, "Auth assertion could not be validated.");

		auto jres = cres.readJson();
		enforceHttp(jres.status.get!string == "okay", HttpStatus.Unauthorized, "Auth assertion is invalid.");

		Session session = req.session;
		if( !session ) session = res.startSession();
		session["email"] = jres.email.get!string;
		res.writeJsonBody(jres);
	}

	private void logout(HttpServerRequest req, HttpServerResponse res)
	{
		if( req.session ) res.terminateSession();
		res.writeJsonBody(["message": "Successfully logged out."]);
	}
}
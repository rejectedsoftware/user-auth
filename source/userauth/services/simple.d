module userauth.services.simple;

import userauth.userauth;

import vibe.stream.memory;
import vibe.templ.diet;


class SimpleAuthService : UserAuthService {
	string generateAuthMixin(HTTPServerRequest req, string path_prefix)
	{
		auto dst = new MemoryOutputStream;
		parseDietFileCompat!("userauth-simple-auth-mixin.dt",
			string, "path_prefix")(dst, path_prefix);
		return cast(string)dst.data();
	}

	void registerRoutes(URLRouter router, string path_prefix)
	{
		router.post(path_prefix~"login", &login);
	}

	void login(HTTPServerRequest req, HTTPServerResponse res)
	{
		
	}
}
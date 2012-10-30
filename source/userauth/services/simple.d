module userauth.services.simple;

import userauth.userauth;

import vibe.stream.memory;
import vibe.templ.diet;


class SimpleAuthService : UserAuthService {
	string generateAuthMixin(HttpServerRequest req, string path_prefix)
	{
		auto dst = new MemoryOutputStream;
		parseDietFileCompat!("userauth-simple-auth-mixin.dt",
			string, "path_prefix")(dst, Variant(path_prefix));
		return cast(string)dst.data();
	}

	void registerRoutes(UrlRouter router, string path_prefix)
	{
		router.post(path_prefix~"login", &login);
	}

	void login(HttpServerRequest req, HttpServerResponse res)
	{
		
	}
}
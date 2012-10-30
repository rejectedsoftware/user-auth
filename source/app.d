import vibe.d;

import userauth.userauth;
import userauth.services.persona;
import userauth.services.simple;

static this()
{
	setLogLevel(LogLevel.Debug);
	auto router = new UrlRouter;

	auto auth = new UserAuth(router, "/");
	auth.register(new PersonaAuthService);
	auth.register(new SimpleAuthService);

	void home(HttpServerRequest req, HttpServerResponse res)
	{
		res.renderCompat!("test.dt",
			HttpServerRequest, "req",
			UserAuth, "auth")(Variant(req), Variant(auth));
	}
	router.get("/", &home);

	auto settings = new HttpServerSettings;
	settings.port = 8080;
	settings.sessionStore = new MemorySessionStore;
	listenHttp(settings, router);
}
import vibe.d;

import userauth.userauth;
import userauth.services.persona;
import userauth.services.simple;

shared static this()
{
	setLogLevel(LogLevel.debugV);
	auto router = new URLRouter;

	auto auth = new UserAuth(router, "/");
	auth.register(new PersonaAuthService);
	auth.register(new SimpleAuthService);

	void home(HTTPServerRequest req, HTTPServerResponse res)
	{
		res.renderCompat!("test.dt",
			HTTPServerRequest, "req",
			UserAuth, "auth")(req, auth);
	}
	router.get("/", &home);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.sessionStore = new MemorySessionStore;
	listenHTTP(settings, router);
}
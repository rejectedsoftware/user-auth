module userauth.userauth;

public import vibe.http.router;

interface UserAuthService {
	string generateAuthMixin(HttpServerRequest req, string path_prefix);
	void registerRoutes(UrlRouter router, string path_prefix);
}

struct UserAuthInfo {
	bool authenticated;
	string htmlMixin;
	UserAuthService authService;
	string email;
	string fullName;
}

class UserAuth {
	private {
		UserAuthService[] m_services;
		UrlRouter m_router;
		string m_pathPrefix;
	}
	
	this(UrlRouter router, string path_prefix = "/")
	{
		m_router = router;
		m_pathPrefix = path_prefix;
	}

	void register(UserAuthService service)
	{
		m_services ~= service;
		service.registerRoutes(m_router, m_pathPrefix);
	}

	string generateAuthMixinList(HttpServerRequest req)
	{
		string ret;
		foreach( s; m_services ) ret ~= s.generateAuthMixin(req, m_pathPrefix);
		return ret;
	}

	UserAuthInfo getAuthInfo(HttpServerRequest req)
	{
		UserAuthInfo ret;
		ret.htmlMixin = generateAuthMixinList(req);
		ret.authenticated = req.session !is null;
		if( req.session ){
			ret.email = req.session["email"];
		}
		return ret;
	}
}

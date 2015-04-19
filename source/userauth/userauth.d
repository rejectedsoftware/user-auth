module userauth.userauth;

public import vibe.http.router;

interface UserAuthService {
	string generateAuthMixin(HTTPServerRequest req, string path_prefix);
	void registerRoutes(URLRouter router, string path_prefix);
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
		URLRouter m_router;
		string m_pathPrefix;
	}
	
	this(URLRouter router, string path_prefix = "/")
	{
		m_router = router;
		m_pathPrefix = path_prefix;
	}

	void register(UserAuthService service)
	{
		m_services ~= service;
		service.registerRoutes(m_router, m_pathPrefix);
	}

	string generateAuthMixinList(HTTPServerRequest req)
	{
		string ret;
		foreach( s; m_services ) ret ~= s.generateAuthMixin(req, m_pathPrefix);
		return ret;
	}

	UserAuthInfo getAuthInfo(HTTPServerRequest req)
	{
		UserAuthInfo ret;
		ret.htmlMixin = generateAuthMixinList(req);
		ret.authenticated = req.session.id !is null;
		if( req.session ){
			ret.email = req.session.get!string("email");
		}
		return ret;
	}
}

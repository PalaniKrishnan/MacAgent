
#import "AuthPlugin.h"

/*
	AuthorizationPluginCreate - The main entry point for a SecurityAgent plugin.
		The AuthPlugin class will fill in the outPluginInterface values
*/
OSStatus
AuthorizationPluginCreate(const AuthorizationCallbacks *callbacks,
                          AuthorizationPluginRef *outPlugin,
                          const AuthorizationPluginInterface **outPluginInterface)
{
    *outPlugin = [[EXAuthPlugin alloc] initWithCallbacks:callbacks pluginInterface:outPluginInterface];
    return noErr;
}

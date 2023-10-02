
#import "plugin-objc.h"

//Plugin API calls
OSStatus PluginDestroy(AuthorizationPluginRef inPlugin);
OSStatus MechanismCreate(AuthorizationPluginRef inPlugin,
			 AuthorizationEngineRef inEngine,
			 AuthorizationMechanismId mechanismId,
			 AuthorizationMechanismRef *outMechanism);
//Mechanism API calls
OSStatus MechanismInvoke(AuthorizationMechanismRef inMechanism);
OSStatus MechanismDeactivate(AuthorizationMechanismRef inMechanism);
OSStatus MechanismDestroy(AuthorizationMechanismRef inMechanism);

// All API calls only exported via plugin interface
static AuthorizationPluginInterface mAuthorizationPluginInterface =
{
	kAuthorizationPluginInterfaceVersion,
	&PluginDestroy,
	&MechanismCreate,
	&MechanismInvoke,
	&MechanismDeactivate,
	&MechanismDestroy 
};

__private_extern__ OSStatus PluginDestroy(AuthorizationPluginRef inPlugin)
{
	// this is static
	[(EXAuthorizationPlugin*)inPlugin release];
	return 0; //errSuccess;
}

__private_extern__ OSStatus MechanismCreate(AuthorizationPluginRef inPlugin,
	AuthorizationEngineRef inEngine,
	AuthorizationMechanismId mechanismId,
	AuthorizationMechanismRef *outMechanism)
{
	*outMechanism = [(EXAuthorizationPlugin *)inPlugin mechanism:mechanismId engineRef:inEngine];

	if (*outMechanism)
		return noErr;
	else
		return errAuthorizationInternal; // No such mechanism
}

__private_extern__ OSStatus MechanismInvoke(AuthorizationMechanismRef inMechanism)
{
	return [(EXAuthorizationMechanism *)inMechanism invoke];
}

__private_extern__ OSStatus MechanismDeactivate(AuthorizationMechanismRef inMechanism)
{
	return [(EXAuthorizationMechanism *)inMechanism deactivate];
}

__private_extern__ OSStatus MechanismDestroy(AuthorizationMechanismRef inMechanism)
{
	[(EXAuthorizationMechanism *)inMechanism release];
	return noErr;
}



@implementation EXAuthorizationPlugin

- (AuthorizationCallbacks *)engineCallback
{
	return mEngineInterface;
}

- (id)initWithCallbacks:(const AuthorizationCallbacks *)callbacks pluginInterface:(const AuthorizationPluginInterface **)interface
{
	if ([super init] != nil)
	{
		// call backs into the engine
		mEngineInterface = (AuthorizationCallbacks *)callbacks;
		// publish plugin's api
		*interface = &mAuthorizationPluginInterface;
		return self;
	} else
		return nil;
}

- (id)setCallbacks:(const AuthorizationCallbacks *)callbacks pluginInterface:(const AuthorizationPluginInterface **)interface
{
	assert(mEngineInterface == callbacks);
	mEngineInterface = (AuthorizationCallbacks *)callbacks;
	*interface = &mAuthorizationPluginInterface;
	return self;
}

// This is a factory method
// You need to override it to produce all the mechanism your plugin provides
- (id)mechanism:(AuthorizationMechanismId)mechanismId engineRef:(AuthorizationEngineRef)inEngine
{
	// ignore mechanismId, there is only one:
	return [[EXAuthorizationMechanism alloc] initWithPlugin:self engineRef:inEngine];
}

@end //EXAuthorizationPlugin



@implementation EXAuthorizationMechanism

- (id)init
{
	[super init];
	return self;
}

- (id)initWithPlugin:(EXAuthorizationPlugin *)plugin engineRef:(AuthorizationEngineRef)engine
{
	if ([self init] != nil)
	{
		// plugin gives us access to plugin callbacks
		mPluginRef = plugin;
		// engine requires us to identify ourselves to it by it's chosen handle
		mEngineRef = engine;
		return self;
	} else
		return nil;
}

- (OSStatus)requestInterrupt
{
	return [mPluginRef engineCallback]->RequestInterrupt(mEngineRef);
}

- (OSStatus)setResult:(AuthorizationResult)inResult
{
	return [mPluginRef engineCallback]->SetResult(mEngineRef, inResult);
}

- (OSStatus)didDeactivate
{
	return [mPluginRef engineCallback]->DidDeactivate(mEngineRef);
}

- (OSStatus)getContext:(AuthorizationString)inKey flags:(AuthorizationContextFlags *)outContextFlags value:(const AuthorizationValue **)outValue
{
	return [mPluginRef engineCallback]->GetContextValue(mEngineRef, inKey, outContextFlags, outValue);
}

- (OSStatus)setContext:(AuthorizationString)inKey flags:(AuthorizationContextFlags)inContextFlags value:(const AuthorizationValue *)inValue
{
	return [mPluginRef engineCallback]->SetContextValue(mEngineRef, inKey, inContextFlags, inValue);
}

- (OSStatus)getHint:(AuthorizationString)inKey value:(const AuthorizationValue **)outValue
{
	return [mPluginRef engineCallback]->GetHintValue(mEngineRef, inKey, outValue);
}

- (OSStatus)setHint:(AuthorizationString)inKey value:(const AuthorizationValue *)inValue
{
	return [mPluginRef engineCallback]->SetHintValue(mEngineRef, inKey, inValue);
}

- (OSStatus)getArguments:(const AuthorizationValueVector **)outArguments
{
	return [mPluginRef engineCallback]->GetArguments(mEngineRef, outArguments);
}

- (OSStatus)getSession:(AuthorizationSessionId *)outSessionId
{
	return [mPluginRef engineCallback]->GetSessionId(mEngineRef, outSessionId);
}


- (OSStatus)invoke
{
	// put code here
	return noErr;
}

- (OSStatus)deactivate
{
	return [self didDeactivate];
}

@end //EXAuthorizationMechanism


@implementation EXAuthorizationMechanism ( ConvenienceAccessors )

- (NSData *)hintNSData:(const char *)inKey
{
	const AuthorizationValue *authvalue = NULL;

	if ([mPluginRef engineCallback]->GetHintValue(mEngineRef, inKey, &authvalue) 
	|| (authvalue == NULL)
	|| (authvalue->data == NULL))
		return nil;
	return [NSData dataWithBytes:authvalue->data length:authvalue->length];
}

- (NSData *)contextNSData:(const char *)inKey
{
	const AuthorizationValue *authvalue = NULL;
	AuthorizationContextFlags authflags;

	if ([mPluginRef engineCallback]->GetContextValue(mEngineRef, inKey, &authflags, &authvalue) 
	|| (authvalue == NULL)
	|| (authvalue->data == NULL))
		return nil;
	return [NSData dataWithBytes:authvalue->data length:authvalue->length];
}

- (NSString *)contextString:(const char *)inKey
{
	NSData *authData = [self contextNSData:inKey];
	if (authData)
		return [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] autorelease];
	return nil;
}

- (void)setContextString:(NSString *)value withFlags:(AuthorizationFlags)flags forKey:(const char *)inKey
{
	const char *utf8string = [value UTF8String];
	AuthorizationValue authvalue = { utf8string ? strlen(utf8string) : 0, (char *)utf8string };
	[mPluginRef engineCallback]->SetContextValue(mEngineRef, inKey, (AuthorizationContextFlags)flags, &authvalue);
}

- (NSString *)hintString:(const char *)inKey
{
	NSData *authData = [self hintNSData:inKey];
	if (authData)
		return [[[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding] autorelease];
	return nil;
}

- (void)setHintString:(NSString *)value forKey:(const char *)inKey
{
	const char *utf8string = [value UTF8String];
	AuthorizationValue authvalue = { utf8string ? strlen(utf8string) : 0, (char *)utf8string };
	[mPluginRef engineCallback]->SetHintValue(mEngineRef, inKey, &authvalue);
}



- (BOOL)hintData:(uint8_t*)data withSize:(size_t)size forKey:(const char *)inKey
{
	const AuthorizationValue *authvalue = NULL;

	if ([mPluginRef engineCallback]->GetHintValue(mEngineRef, inKey, &authvalue) 
		|| (authvalue == NULL)
		|| (authvalue->data == NULL)
		|| (authvalue->length != size))
		return NO;

	if (data)
		bcopy((uint8_t*)authvalue->data, data, size);

	return YES;
}

- (BOOL)contextData:(uint8_t*)data withSize:(size_t)size withFlags:(AuthorizationContextFlags*)flags forKey:(const char *)inKey
{
	const AuthorizationValue *authvalue = NULL;
	AuthorizationContextFlags authflags;

	if ([mPluginRef engineCallback]->GetContextValue(mEngineRef, inKey, &authflags, &authvalue) 
		|| (authvalue == NULL)
		|| (authvalue->data == NULL)
		|| (authvalue->length != size))
		return NO;

	if (data)
		bcopy((uint8_t*)authvalue->data, data, size);
	if (flags)
		*flags = authflags;

	return YES;
}

- (BOOL)setContextData:(uint8_t*)data withSize:(size_t)size withFlags:(AuthorizationContextFlags)flags forKey:(const char *)inKey
{
	AuthorizationValue authvalue = { size, data };

	if ([mPluginRef engineCallback]->SetContextValue(mEngineRef, inKey, flags, &authvalue))
		return NO;

	return YES;
}


@end //EXAuthorizationMechanism ( ConvenienceAccessors )


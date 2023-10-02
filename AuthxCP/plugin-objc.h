#import <Foundation/Foundation.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>
#import <Security/AuthorizationPlugin.h>

#ifndef __H_PLUGIN_OBJC__
#define __H_PLUGIN_OBJC__


@interface EXAuthorizationPlugin : NSObject
{
@protected
	AuthorizationCallbacks *mEngineInterface;
@private
	void *_internal;
}

-(id)initWithCallbacks:(const AuthorizationCallbacks *)callbacks pluginInterface:(const AuthorizationPluginInterface **)interface;
-(id)setCallbacks:(const AuthorizationCallbacks *)callbacks pluginInterface:(const AuthorizationPluginInterface **)interface;

-(AuthorizationCallbacks*)engineCallback;

// factory method: create mechanisms for this plugin based on mechanismId
-(id)mechanism:(AuthorizationMechanismId)mechanismId engineRef:(AuthorizationEngineRef)inEngine;

@end


@interface EXAuthorizationMechanism : NSObject
{
@protected
	EXAuthorizationPlugin *mPluginRef; // AuthorizationPluginRef
	AuthorizationEngineRef mEngineRef;
@private
	void *_internal;
}

- (id)init;
- (id)initWithPlugin:(EXAuthorizationPlugin*)plugin engineRef:(AuthorizationEngineRef)engine;

- (OSStatus)invoke;
- (OSStatus)deactivate;

- (OSStatus)requestInterrupt;
- (OSStatus)setResult:(AuthorizationResult)inResult;
- (OSStatus)didDeactivate;

- (OSStatus)getContext:(AuthorizationString)inKey flags:(AuthorizationContextFlags *)outContextFlags value:(const AuthorizationValue **)outValue;
- (OSStatus)setContext:(AuthorizationString)inKey flags:(AuthorizationContextFlags)inContextFlags value:(const AuthorizationValue *)inValue;
- (OSStatus)getHint:(AuthorizationString)inKey value:(const AuthorizationValue **)outValue;
- (OSStatus)setHint:(AuthorizationString)inKey value:(const AuthorizationValue *)inValue;
- (OSStatus)getArguments:(const AuthorizationValueVector **)outArguments;
- (OSStatus)getSession:(AuthorizationSessionId *)outSessionId;

@end 


@interface EXAuthorizationMechanism ( ConvenienceAccessors )

- (NSData *)hintNSData:(const char *)inKey;
- (NSData *)contextNSData:(const char *)inKey;
- (NSString *)contextString:(const char *)inKey;
- (void)setContextString:(NSString *)value withFlags:(AuthorizationFlags)flags forKey:(const char *)inKey;
- (NSString *)hintString:(const char *)inKey;
- (void)setHintString:(NSString *)value forKey:(const char *)inKey;
- (BOOL)hintData:(uint8_t*)data withSize:(size_t)size forKey:(const char *)inKey;
- (BOOL)contextData:(uint8_t*)data withSize:(size_t)size withFlags:(AuthorizationContextFlags*)flags forKey:(const char *)inKey;
- (BOOL)setContextData:(uint8_t*)data withSize:(size_t)size withFlags:(AuthorizationContextFlags)flags forKey:(const char *)inKey;

@end


#endif /* __H_PLUGIN_OBJC__ */
		


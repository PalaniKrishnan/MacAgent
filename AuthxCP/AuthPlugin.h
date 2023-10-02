

#import <Cocoa/Cocoa.h>
#import "plugin-objc.h"
#import "zKeyCPPlugin.h"
#import "AuthxCP-Swift.h"
// --------------------------------------------------------------------------------

@interface EXAuthPlugin : EXAuthorizationPlugin {}
- (id)mechanism:(AuthorizationMechanismId)mechanismId engineRef:(AuthorizationEngineRef)inEngine;
@end

@interface EXAuthPluginMechanism : EXAuthorizationMechanism
{
    EXNameAndPasswordEx			*mNameAndPassword;
    CheckAD     *checkAD;
}
- (OSStatus)invoke;
@end


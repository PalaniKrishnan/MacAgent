
#import "AuthPlugin.h"

// --------------------------------------------------------------------------------

@implementation EXAuthPlugin

-(id)mechanism:(AuthorizationMechanismId)mechanismId engineRef:(AuthorizationEngineRef)inEngine
{
	if (!strcmp(mechanismId, "invoke"))
	{
		// for the invoke mechanism return a instance of the AuthPluginMechanism
		return [[EXAuthPluginMechanism alloc] initWithPlugin:self engineRef:inEngine];
	}
	
    return nil;
}
@end
// --------------------------------------------------------------------------------

@implementation EXAuthPluginMechanism

- (OSStatus)invoke
{
	if (mNameAndPassword == nil)
	{
		mNameAndPassword = [[EXNameAndPasswordEx alloc] initWithCallbacks: [mPluginRef engineCallback] andEngineRef: mEngineRef];
	}

	if (mNameAndPassword)
	{
		//[mNameAndPassword displayView];
        [mNameAndPassword updateView];
	}
    
    
    //checkAD = [[CheckAD alloc] initWithCallbacks:[mPluginRef engineCallback] //andEngineRef:mEngineRef sfAuthPluginView:self];
    
    
    
    //[checkAD run];
    
	return noErr;
}
// --------------------------------------------------------------------------------
- (OSStatus)deactivate
{
    if (mNameAndPassword)
    {
        [mNameAndPassword release];
    }
    
    [super dealloc];
    
    return noErr;
}

- (void)dealloc
{
	if (mNameAndPassword)
	{
		[mNameAndPassword release];
	}
	
	[super dealloc];
}

@end

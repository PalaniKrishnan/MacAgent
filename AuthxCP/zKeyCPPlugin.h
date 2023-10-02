
#import <Cocoa/Cocoa.h>
#import <SecurityInterface/SFAuthorizationPluginView.h>
#import "AuthxCP-Swift.h"

// --------------------------------------------------------------------------------
@interface EXNameAndPasswordEx : SFAuthorizationPluginView
{
	IBOutlet NSView				*mIdentityAndPasswordView;
	IBOutlet NSTextField		*mNameTextField;
	IBOutlet NSSecureTextField	*mIPPasswordSecureTextField;
	
	IBOutlet NSView				*mPasswordView;
	IBOutlet NSSecureTextField	*mPPasswordSecureTextField;
	
	NSString					*mUserName;
	BOOL						mUseIPView;
    int                         m_nValue;
    
    IBOutlet NSButton *NSBtnSwitchView;
    
    IBOutlet NSTextField *mZighraLabel;
    IBOutlet NSButton *NSBtnBack;
    NSTimer *_timer;
    
    NSTimer *_poolingtimer;
    
    CheckAD     *checkAD;
}
- (void)updateView;
- (void)invokeSA;
// --------------------------------------------------------------------------------

@end

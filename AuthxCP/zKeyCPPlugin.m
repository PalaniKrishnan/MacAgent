
#import "zKeyCPPlugin.h"
#import <Security/AuthorizationTags.h>
#import "CryptLib.h"

// --------------------------------------------------------------------------------

@implementation EXNameAndPasswordEx

// --------------------------------------------------------------------------------

- (void)buttonPressed:(SFButtonType)inButtonType
{
    NSString *userNameString;
    NSString *passwordString;
    
    // check which type of view was asked for
    if (mUseIPView)
    {
        // it was the Identity and Credentials view so use the name field to get the user's identity
        userNameString = [mNameTextField stringValue];
        passwordString = [mIPPasswordSecureTextField stringValue];
    }
    else
    {
        // it was just the Credentials view so use the existing user name
        userNameString = mUserName;
        passwordString = [mPPasswordSecureTextField stringValue];
    }
    
    // if the OK button was pressed, write the identity and credentials and allow authorization,
    // otherwise, if the cancel button was pressed, cancel the authorization
    
    if (inButtonType == SFButtonTypeOK)
    {
        const char *userName = [userNameString UTF8String];
        const char *password = [passwordString UTF8String];
        
        AuthorizationValue userNameValue = { strlen(userName) + 1, (char*)userName };
        AuthorizationValue userPasswordValue = { strlen(password) + 1, (char*)password };
        
        NSString *sUserData = [NSString stringWithFormat:@"%@:%@",userNameString, passwordString];
        //[writeUserData sUserData: sUserData];
        [self writeUserData:sUserData];
        // add the username and password to the context values
        [self callbacks]->SetContextValue([self engineRef], kAuthorizationEnvironmentUsername, 1, &userNameValue);
        [self callbacks]->SetContextValue([self engineRef], kAuthorizationEnvironmentPassword, 1, &userPasswordValue);
        
        // allow authorization
        [self callbacks]->SetResult([self engineRef], kAuthorizationResultAllow);
        
    }
    else if (inButtonType == SFButtonTypeCancel)
    {
        // cancel authorization
        [self callbacks]->SetResult([self engineRef], kAuthorizationResultUserCanceled); 
    }
}
// --------------------------------------------------------------------------------

- (NSView *)firstKeyView
{
	// return the appropriate view depending on whether or not identity and credentials
	// or just credentials are being asked for
	if (mUseIPView)
		return mNameTextField;
	else
		return mPPasswordSecureTextField;
}
// --------------------------------------------------------------------------------

- (NSView *)firstResponderView
{
	NSView					*view;
	
	// return the appropriate view depending on whether or not identity and credentials
	// or just credentials are being asked for
	if (mUseIPView)
	{
		// if the name field doesn't already has a user name, then return the name text field view
		// otherwise, return the password secure text field
		if ([[mNameTextField stringValue] length] == 0)
		{
			view = mNameTextField;
		}
		else
		{
			view = mIPPasswordSecureTextField;
		}
	}
	else
	{
		view = mPPasswordSecureTextField;
	}
	
	return view;
}
// --------------------------------------------------------------------------------

- (NSView *)lastKeyView
{
	// return the appropriate view depending on whether or not identity and credentials
	// or just credentials are being asked for
	if (mUseIPView)
		return mIPPasswordSecureTextField;
	else
		return mPPasswordSecureTextField;
}
// --------------------------------------------------------------------------------

- (void)setEnabled:(BOOL)inEnabled
{
	// enable or disable the text fields as appropriate
	[mNameTextField setEnabled: inEnabled];
	[mIPPasswordSecureTextField setEnabled: inEnabled];
	[mPPasswordSecureTextField setEnabled: inEnabled];
}
// --------------------------------------------------------------------------------

- (void)willActivateWithUser:(NSDictionary *)inUserInformation
{
	// save the user name and set the name text field
	/*mUserName = [[inUserInformation objectForKey: SFAuthorizationPluginViewUserShortNameKey] retain];
	if (mUserName)
	{
		[mNameTextField setStringValue: mUserName];
	}*/
    //[checkAD run];
}
// --------------------------------------------------------------------------------

- (NSView*)viewForType:(SFViewType)inType
{
	NSView *view = nil;
    
	// return the appropriate view for the type of view being requested
	if (inType == SFViewTypeIdentityAndCredentials)
	{
		view = mIdentityAndPasswordView;
		mUseIPView = YES;
	}
	else if (inType == SFViewTypeCredentials)
	{
		view = mPasswordView;
		mUseIPView = NO;
	}
    
	return view;
}
// --------------------------------------------------------------------------------

- (NSString*)readUserData:(NSString*)sUser {
    
    NSString *filepath = @"/Users/Shared/zkey_users.ini";
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSData* data = [filemgr contentsAtPath: filepath ];
    NSString* string = [[NSString alloc] initWithBytes:[data bytes]
                                                length:[data length]
                                              encoding:NSUTF8StringEncoding];
    NSString* password = @"nil";
    NSString* delimiter = @"\n";
    NSArray *linesArray = [string componentsSeparatedByString:delimiter];
    
    for (NSString *lingObj in linesArray) {
        NSString* fielddelimiter = @",";
        NSArray *fields = [lingObj componentsSeparatedByString:fielddelimiter];
        if([[fields[0] lowercaseString] isEqual:[sUser lowercaseString]])
        {
            password = fields[2];
            break;
        }
    }
    
    return password;
    // Do any additional setup after loading the view.
}

// --------------------------------------------------------------------------------

- (NSString*)readUserDomain:(NSString*)sUser {
    
    NSString *filepath = @"/Users/Shared/zkey_users.ini";
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSData* data = [filemgr contentsAtPath: filepath ];
    NSString* string = [[NSString alloc] initWithBytes:[data bytes]
                                                length:[data length]
                                              encoding:NSUTF8StringEncoding];
    NSString* domain = @"nil";
    NSString* delimiter = @"\n";
    NSArray *linesArray = [string componentsSeparatedByString:delimiter];
    
    for (NSString *lingObj in linesArray) {
        NSString* fielddelimiter = @",";
        NSArray *fields = [lingObj componentsSeparatedByString:fielddelimiter];
        if([[fields[0] lowercaseString] isEqual:[sUser lowercaseString]])
        {
            domain = fields[4];
            break;
        }
    }
    
    return domain;
    // Do any additional setup after loading the view.
}
// --------------------------------------------------------------------------------

-(void) theAction {
    
    [checkAD run];
    
    [_timer invalidate];

    _timer = nil;
    
}

- (void)updateView {
    [super displayView];
    //[checkAD run];
     _timer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                      target:self
                                    selector:@selector(theAction)
                                    userInfo:nil
                                     repeats:YES];
    
}

// --------------------------------------------------------------------------------

- (void) NSBtnSwitchView_action: (NSButton*)button{
    //your code
    
   /* [mNameTextField setHidden:TRUE];
    [mIPPasswordSecureTextField setHidden:TRUE];
    [mPPasswordSecureTextField setHidden:TRUE];

    [mZighraLabel setHidden:FALSE];
    [NSBtnBack setHidden:FALSE];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(theAction)
                                   userInfo:nil
                                    repeats:YES];
    */
    
    [checkAD run];
    
}

- (void)didActivate {
    
   /* _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(theAction)
                                   userInfo:nil
                                    repeats:YES];
    */
}

// --------------------------------------------------------------------------------
- (void) NSBtnBack_action: (NSButton*)button{
    //your code
    
    [mNameTextField setHidden:FALSE];
    [mIPPasswordSecureTextField setHidden:FALSE];
    [mPPasswordSecureTextField setHidden:FALSE];
    
    [mZighraLabel setHidden:TRUE];
    [NSBtnBack setHidden:TRUE];
    
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    
}
// --------------------------------------------------------------------------------
- (id)initWithCallbacks:(const AuthorizationCallbacks *)callbacks andEngineRef:(AuthorizationEngineRef)engineRef
{
	self = [super initWithCallbacks: callbacks andEngineRef: engineRef];
    
    checkAD = [[CheckAD alloc] initWithCallbacks:callbacks andEngineRef:engineRef engineView:self];
    
	if (self)
	{
        m_nValue = 0;
        
        [NSBtnSwitchView setTarget:self];
        [NSBtnSwitchView setAction:@selector(NSBtnSwitchView_action:)];
        
        [NSBtnBack setTarget:self];
        [NSBtnBack setAction:@selector(NSBtnBack_action:)];
        
        [mZighraLabel setHidden:TRUE];
        [NSBtnBack setHidden:TRUE];
        
	}       
    
	return self;
}

- (void)dealloc
{
	[mUserName release];
	[super dealloc];
}

@end

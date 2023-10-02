//
//  main.m
//  zKeyInstallerHelp
//
//  Created by Shahzad on 10/20/19.
//  Copyright © 2019 Shahzad. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* runCommand (NSString* commandToRun)
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

BOOL runProcessAsAdministrator(NSString* scriptPath) {
    
    //NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@", scriptPath];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (!eventResult)
    {
        // Describe common errors
        return NO;
    }
    else
    {
        
        return YES;
    }
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        runCommand(@"security authorizationdb read system.login.console > outfile.plist");
        
        NSError * error;
        NSString * stringFromFile;
        NSString * stringFilepath = @"outfile.plist";
        stringFromFile = [[NSString alloc] initWithContentsOfFile:stringFilepath
                                                         encoding:NSWindowsCP1250StringEncoding
                                                            error:&error];
        
        NSString *copy = [stringFromFile stringByReplacingOccurrencesOfString:@"loginwindow:login" withString:@"AuthxCP:invoke"];
        //NSString *copy = [stringFromFile stringByReplacingOccurrencesOfString:@"zKeyCP:invoke" withString:@"loginwindow:login"];
        [copy writeToFile:stringFilepath atomically:YES encoding:NSWindowsCP1250StringEncoding error:&error];
        
        BOOL bSuccess = runProcessAsAdministrator(@"security authorizationdb write system.login.console < outfile.plist\\ndefaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool false");
        
        if(bSuccess==YES)
            printf("Successfully configured authx credential manager.");
        else
            printf("Failed to configure authx credential manager.");
        
        runCommand(@"defaults write /Library/Preferences/com.apple.loginwindow PowerOffDisabled -bool false");
        
    }
    return 0;
}

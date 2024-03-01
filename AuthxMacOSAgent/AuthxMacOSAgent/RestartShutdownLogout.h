//
//  RestartShutdownLogout.h
//  AuthxMacOSAgent
//
//  Created by pkrishnan on 3/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RestartShutdownLogout : NSObject
-(void)sendSystemEvent:(int)command;
@end


NS_ASSUME_NONNULL_END

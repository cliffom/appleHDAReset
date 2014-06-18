//
//  SPHelper.h
//  audioreset
//
//  Created by Michael Clifford on 6/17/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPHelper : NSObject
+ (BOOL)runProcessAsAdministrator:(NSString *)scriptPath
                     userPassword:(NSString *)userPassword
                    withArguments:(NSArray *)arguments
                           output:(NSString **)output
                 errorDescription:(NSString **)errorDescription;
@end

//
//  SPHelper.h
//  audioreset
//
//  Created by Michael Clifford on 6/17/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPHelper : NSObject

@property NSString *output;
@property NSString *errorDescription;

- (BOOL)runProcessAsAdministrator:(NSString *)scriptPath
                     userPassword:(NSString *)userPassword
                    withArguments:(NSArray *)arguments;
@end

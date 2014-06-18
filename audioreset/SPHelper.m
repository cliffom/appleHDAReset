//
//  SPHelper.m
//  audioreset
//
//  Created by Michael Clifford on 6/17/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import "SPHelper.h"

@implementation SPHelper

- (id)init {
    self = [super init];
    return self;
}

//
// Credit to the stackoverflow thread at
// http://stackoverflow.com/questions/6841937/authorizationexecutewithprivileges-is-deprecated
//
- (BOOL)runProcessAsAdministrator:(NSString*)scriptPath
                     userPassword: (NSString *)userPassword
                    withArguments:(NSArray *)arguments {

    NSString *allArgs = [arguments componentsJoinedByString:@" "];
    NSString *fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    NSString *script;
    NSDictionary *errorInfo = [NSDictionary new];
    NSAppleScript *appleScript;
    NSAppleEventDescriptor *eventResult;

    if (userPassword.length > 0) {
        userPassword = [NSString stringWithFormat:@"password \"%@\"", userPassword];
    } else {
        userPassword = @"";
    }

    script = [NSString stringWithFormat:@"do shell script \"%@\" %@ with administrator privileges", fullScript, userPassword];

    appleScript = [[NSAppleScript new] initWithSource:script];
    eventResult = [appleScript executeAndReturnError:&errorInfo];

    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        _errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                _errorDescription = @"The administrator password is required to do this.";
        }

        // Set error message from provided message
        if (_errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                _errorDescription = (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }

        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        _output = [eventResult stringValue];

        return YES;
    }
}
@end

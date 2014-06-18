//
//  SPHelper.m
//  audioreset
//
//  Created by Michael Clifford on 6/17/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import "SPHelper.h"

@implementation SPHelper
//
// Credit to the stackoverflow thread at
// http://stackoverflow.com/questions/6841937/authorizationexecutewithprivileges-is-deprecated
//
+ (BOOL)runProcessAsAdministrator:(NSString*)scriptPath
                     userPassword: (NSString *)userPassword
                    withArguments:(NSArray *)arguments
                           output:(NSString **)output
                 errorDescription:(NSString **)errorDescription {

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
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }

        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }

        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];

        return YES;
    }
}
@end

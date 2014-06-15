//
//  SPAppDelegate.m
//  audioreset
//
//  Created by Michael Clifford on 6/13/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import "SPAppDelegate.h"

@implementation SPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.title = @"";
    self.statusItem.highlightMode = YES;
    self.statusItem.image = [NSImage imageNamed:@"Layer_16-01-16.png"];
    [self.statusItem setMenu:self.audioResetMenu];
}

- (IBAction)resetAppleHDAAction:(id)sender {
    [self performSelectorInBackground:@selector(resetAppleHDAInBackground) withObject:nil];
}

- (void)resetAppleHDAInBackground {
    NSString *output = nil;
    NSString *processErrorDescription = nil;
    NSString *resetScript = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/resetHDA.sh"];
    BOOL success = [self runProcessAsAdministrator:resetScript
                                     withArguments:[NSArray arrayWithObjects:nil]
                                            output:&output
                                  errorDescription:&processErrorDescription];
    
    if (!success) {
        NSLog(@"There was an issue:");
        NSLog( @"%@", processErrorDescription );
    }
    else {
        NSLog(@"Success!");
    }
}

//
// Credit to the stackoverflow thread at
// http://stackoverflow.com/questions/6841937/authorizationexecutewithprivileges-is-deprecated
//
- (BOOL)runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
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

//
//  SPAppDelegate.m
//  audioreset
//
//  Created by Michael Clifford on 6/13/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import "SPAppDelegate.h"

@implementation SPAppDelegate

- (void)awakeFromNib {
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"Layer_16-01-16.png"];
    [_statusItem setMenu:_audioResetMenu];
}

#pragma mark -
#pragma mark IBActions

- (IBAction)openAboutWindow:(id)sender {
    [self openWindow:_aboutWindow sender:sender];
}

- (IBAction)openPreferencesWindow:(id)sender {
    [self openWindow:_preferencesWindow sender:sender];
}

- (IBAction)toggleAddToLoginItems:(id)sender {
    if ([sender state] == NSOnState) {
		[[NSBundle mainBundle] addToLoginItems];
    } else {
		[[NSBundle mainBundle] removeFromLoginItems];
    }
}

- (IBAction)resetAppleHDAInBackground:(id)sender {
    [self performSelectorInBackground:@selector(resetAppleHDA) withObject:nil];
}

#pragma mark -
#pragma mark Methods

- (NSString *)bundleVersionNumber {
	return [[[NSBundle mainBundle] infoDictionary]
            objectForKey:@"CFBundleVersion"];
}

- (void)openWindow:(NSWindow *)window
            sender: (id)sender {
    [NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:sender];
}

- (void)receiveWakeNote: (NSNotification*) note
{
    if (_runOnWake.state == NSOnState) {
        [self resetAppleHDAInBackground:nil];
    }
}

- (void)resetAppleHDA {
    NSString *output = nil;
    NSString *processErrorDescription = nil;
    NSString *resetScript = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/Resources/resetHDA.sh"];
    BOOL success = [self runProcessAsAdministrator:resetScript
                                      userPassword:_passwordField.stringValue
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
        userPassword = [NSString stringWithFormat:@"password \"%@\"", self.passwordField.stringValue];
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

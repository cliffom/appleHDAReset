//
//  SPAppDelegate.m
//  audioreset
//
//  Created by Michael Clifford on 6/13/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import "SPAppDelegate.h"
#import "SPHelper.h"

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

- (IBAction)closePreferencesWindow:(id)sender {
    if (_passwordField.stringValue.length > 0) {
        [SSKeychain setPassword:_passwordField.stringValue
                     forService:[[NSBundle mainBundle] bundleIdentifier]
                        account:NSUserName()];
    } else {
        [SSKeychain deletePasswordForService:[[NSBundle mainBundle] bundleIdentifier] account:NSUserName()];
    }
    [_preferencesWindow close];
}

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
    BOOL success = [SPHelper runProcessAsAdministrator:resetScript
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

- (NSString *)userPassword {
    return [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:NSUserName()];
}
@end

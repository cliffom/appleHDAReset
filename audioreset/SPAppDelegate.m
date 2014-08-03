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
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _justLaunched = true;
    if (_hideMenuBarIcon.state == NSOffState) {
        [self setMenuItem];
    }
    [_audioResetMenu setAutoenablesItems:false];
    [_passwordField setEnabled:[_useSavedPassword state]];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!_justLaunched) {
        [self openWindow:_preferencesWindow sender:nil];
    } else {
        _justLaunched = false;
    }
}

#pragma mark -
#pragma mark IBActions

- (IBAction)closeAboutWindow:(id)sender {
    [_aboutWindow close];
}

- (IBAction)closePreferencesWindow:(id)sender {
    if (_passwordField.stringValue.length > 0 && _useSavedPassword.state == NSOnState) {
        [SSKeychain setPassword:_passwordField.stringValue
                     forService:[[NSBundle mainBundle] bundleIdentifier]
                        account:NSUserName()];
    } else {
        [SSKeychain deletePasswordForService:[[NSBundle mainBundle] bundleIdentifier] account:NSUserName()];
        _useSavedPassword.state = NSOffState;
        _passwordField.stringValue = @"";
        [_passwordField setEnabled:false];
    }
    [_resetAppleHDAMenuItem setEnabled:true];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_preferencesWindow close];
}

- (IBAction)openAboutWindow:(id)sender {
    [self openWindow:_aboutWindow sender:sender];
}

- (IBAction)openPreferencesWindow:(id)sender {
    [self openWindow:_preferencesWindow sender:sender];
    [_resetAppleHDAMenuItem setEnabled:false];
}

- (IBAction)resetAppleHDAInBackground:(id)sender {
    [self performSelectorInBackground:@selector(resetAppleHDA) withObject:nil];
}

- (IBAction)toggleAddToLoginItems:(id)sender {
    if ([sender state] == NSOnState) {
		[[NSBundle mainBundle] addToLoginItems];
    } else {
		[[NSBundle mainBundle] removeFromLoginItems];
    }
}

- (IBAction)toggleHideMenuBarIcon:(id)sender {
    if ([sender state] == NSOnState) {
        _statusItem = nil;
    } else {
        [self setMenuItem];
    }
}

- (IBAction)toggleUseSavedPassword:(id)sender {
    if ([sender state] == NSOnState) {
        [_passwordField setEnabled:true];
        [_passwordField becomeFirstResponder];
    } else {
        [_passwordField setEnabled:false];
    }
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
    NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
    NSString *resetScript = [bundlePath stringByAppendingString:@"/Contents/Resources/resetHDA.sh"];
    SPHelper *spHelper = [[SPHelper alloc] init];
    BOOL success = [spHelper runProcessAsAdministrator:resetScript
                                      userPassword:_passwordField.stringValue
                                     withArguments:[NSArray arrayWithObjects:nil]];

    if (!success) {
        [self sendNotification:spHelper.errorDescription];
    }
    else {
        [self sendNotification:@"Your audio system has been reset successfully."];
    }
}

- (void)setMenuItem {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"MenuBarIcon"];
    [_statusItem setMenu:_audioResetMenu];
}

- (void)sendNotification:(NSString *)message {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Reset Audio";
    notification.informativeText = message;
    //notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (NSString *)userPassword {
    return [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:NSUserName()];
}

@end

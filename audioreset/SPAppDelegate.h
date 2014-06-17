//
//  SPAppDelegate.h
//  audioreset
//
//  Created by Michael Clifford on 6/13/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPAppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *audioResetMenu;
@property (weak) IBOutlet NSMenuItem *resetAppleHDA;
@property (unsafe_unretained) IBOutlet NSWindow *aboutWindow;
@property (unsafe_unretained) IBOutlet NSWindow *preferencesWindow;
@property (weak) IBOutlet NSButton *runOnWake;
@property (weak) IBOutlet NSSecureTextField *passwordField;

- (IBAction)openAboutWindow:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)resetAppleHDAAction:(id)sender;
- (void)resetAppleHDAInBackground;
- (BOOL)runProcessAsAdministrator:(NSString *)scriptPath
                     userPassword:(NSString *)userPassword
                    withArguments:(NSArray *)arguments
                           output:(NSString **)output
                 errorDescription:(NSString **)errorDescription;
- (void)openWindow:(NSWindow *)window
            sender:(id)sender;
- (NSString *)bundleVersionNumber;

- (void)receiveWakeNote: (NSNotification*) note;
- (void)fileNotifications;

@end
//
//  SPAppDelegate.h
//  audioreset
//
//  Created by Michael Clifford on 6/13/14.
//  Copyright (c) 2014 Suite Potato. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IYLoginItem/NSBundle+LoginItem.h>
#import <SSKeychain/SSKeychain.h>

@interface SPAppDelegate : NSObject <NSApplicationDelegate>

@property (unsafe_unretained)   IBOutlet NSWindow *aboutWindow;
@property (weak)                IBOutlet NSMenu *audioResetMenu;
@property (weak)                IBOutlet NSSecureTextField *passwordField;
@property (unsafe_unretained)   IBOutlet NSWindow *preferencesWindow;
@property (weak)                IBOutlet NSButton *runOnWake;
@property (strong, nonatomic)   NSStatusItem *statusItem;

- (IBAction)closePreferencesWindow:(id)sender;
- (IBAction)openAboutWindow:(id)sender;
- (IBAction)openPreferencesWindow:(id)sender;
- (IBAction)resetAppleHDAInBackground:(id)sender;
- (IBAction)toggleAddToLoginItems:(id)sender;

- (NSString *)bundleVersionNumber;
- (void)openWindow:(NSWindow *)window sender:(id)sender;
- (void)receiveWakeNote: (NSNotification*) note;
- (void)resetAppleHDA;
- (BOOL)runProcessAsAdministrator:(NSString *)scriptPath
                     userPassword:(NSString *)userPassword
                    withArguments:(NSArray *)arguments
                           output:(NSString **)output
                 errorDescription:(NSString **)errorDescription;
- (NSString *)userPassword;
@end
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
    [self fileNotifications];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.title = @"";
    _statusItem.highlightMode = YES;
    _statusItem.image = [NSImage imageNamed:@"Layer_16-01-16.png"];
    [_statusItem setMenu:_audioResetMenu];
}

- (IBAction)toggleAddToLoginItems:(id)sender {
    if ([sender state] == NSOnState) {
		[self addAppToLoginItems];
    } else {
		[self deleteAppFromLoginItems];
    }

}

- (IBAction)openAboutWindow:(id)sender {
    [self openWindow:_aboutWindow sender:sender];
}

- (IBAction)openPreferencesWindow:(id)sender {
    [self openWindow:_preferencesWindow sender:sender];
}

- (void)openWindow:(NSWindow *)window
            sender: (id)sender {
    [NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:sender];
}

- (IBAction)resetAppleHDAAction:(id)sender {
    [self performSelectorInBackground:@selector(resetAppleHDAInBackground) withObject:nil];
}

- (void)resetAppleHDAInBackground {
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

- (NSString *)bundleVersionNumber {
	return [[[NSBundle mainBundle] infoDictionary]
            objectForKey:@"CFBundleVersion"];
}

- (void)receiveWakeNote: (NSNotification*) note
{
    if (_runOnWake.state == NSOnState) {
        [self resetAppleHDAAction:nil];
    }
}

- (void)fileNotifications
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

-(void) addAppToLoginItems {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];

	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];

	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        if (item){
            CFRelease(item);
        }
	}

	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItems {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];

	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];

	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);

	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i=0; i < [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

@end

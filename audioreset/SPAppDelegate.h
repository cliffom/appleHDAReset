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

- (IBAction)resetAppleHDAAction:(id)sender;
- (BOOL)runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription;


@end

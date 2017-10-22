//
//  PreferencesWindowController.h
//  PrefWindowApp
//
//  Created by Genji on 2012/10/21.
//
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindow : NSWindow

@end

@interface PreferencesWindowController : NSWindowController

+ (PreferencesWindowController *)sharedPreferencesWindowController;

@end

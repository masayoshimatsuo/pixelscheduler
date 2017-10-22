//
//  PreferencesWindowController.m
//  PrefWindowApp
//
//  Created by Genji on 2012/10/21.
//
//

#import "PreferencesWindowController.h"

#pragma mark PreferencesWindow
@implementation PreferencesWindow

- (void)cancelOperation:(id)sender { [self close]; }

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  if([anItem action] == @selector(toggleToolbarShown:)) return NO;
  return [super validateUserInterfaceItem:anItem];
}

@end


#pragma mark -
#pragma mark PreferencesWindowController
enum PreferencesViewType {
  kPreferencesViewTypeGeneral = 100,
  kPreferencesViewTypeAdvanced,
};
typedef NSInteger PreferencesViewType;

@interface PreferencesWindowController ()

@property (weak) IBOutlet NSView *generalView;
@property (weak) IBOutlet NSView *advancedView;

- (IBAction)switchView:(id)sender;

@end

@implementation PreferencesWindowController

+ (PreferencesWindowController *)sharedPreferencesWindowController
{
  static PreferencesWindowController *sharedController = nil;
  if(sharedController == nil) {
    sharedController = [[PreferencesWindowController alloc] init];
  }
  return sharedController;
}

- (id)init
{
  self = [super initWithWindowNibName:@"PreferencesWindowController"];
  if(self) {
    // Initialize
  }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];

  NSWindow *window = [self window];
  NSToolbar *toolbar = [window toolbar];
  NSArray *toolbarItems = [toolbar items];
  NSToolbarItem *leftmostToolbarItem = [toolbarItems objectAtIndex:0];
  [toolbar setSelectedItemIdentifier:[leftmostToolbarItem itemIdentifier]];
  [self switchView:leftmostToolbarItem];
  [window center];
}

#pragma mark -
#pragma mark Action Method
- (IBAction)switchView:(id)sender
{
  NSToolbarItem *item = (NSToolbarItem *)sender;
  PreferencesViewType viewType = [item tag];
  NSView *newView = nil;
  switch(viewType) {
    case kPreferencesViewTypeGeneral: newView = self.generalView; break;
    case kPreferencesViewTypeAdvanced: newView = self.advancedView; break;
    default: return;
  }

  NSWindow *window = [self window];
  NSView *contentView = [window contentView];
  NSArray *subviews = [contentView subviews];
  for(NSView *subview in subviews) [subview removeFromSuperview];

  [window setTitle:[item label]];

  NSRect windowFrame = [window frame];
  NSRect newWindowFrame = [window frameRectForContentRect:[newView frame]];
  newWindowFrame.origin.x = windowFrame.origin.x;
  newWindowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - newWindowFrame.size.height;
  [window setFrame:newWindowFrame display:YES animate:YES];

  [contentView addSubview:newView];
}

@end

//
//  SettingView.h
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/01/31.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "SettingValue.h"

@interface SettingView : NSView<NSTableViewDataSource>

-(void)setAppDel:(id<AppDelegateDel>)appDel;

@end

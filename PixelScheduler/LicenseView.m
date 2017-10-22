//
//  LicenseView.m
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/03/15.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import "LicenseView.h"

@interface LicenseView()

@property (weak) IBOutlet WebView *wv;

@end

@implementation LicenseView

-(void)setAppDel:(id<AppDelegateDel>)appDel
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"];
    [_wv setMainFrameURL:path];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end

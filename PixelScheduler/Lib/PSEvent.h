//
//  PSEvent.h
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/03/21.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import <EventKit/EventKit.h>

@interface PSEvent : NSObject

@property(nonatomic)NSColor *color;
@property(nonatomic)EKEvent *evn;

@end

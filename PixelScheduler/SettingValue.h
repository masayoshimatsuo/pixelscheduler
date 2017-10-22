//
//  SettingValue.h
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2014/12/21.
//  Copyright (c) 2014年 dao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMTimerBeam.h"

@interface SettingValue : NSObject <NSCoding,NSCopying>

@property(nonatomic)NSNumber  *selCal;
@property(nonatomic)NSNumber  *barPos;
@property(nonatomic)NSNumber  *barWidth;
@property(nonatomic)NSNumber  *upDate;
@property(nonatomic)NSNumber  *enablePop;
@property(nonatomic)NSNumber  *enableStartUp;


-(JMTimerBeamOrientations)getPos;
-(NSInteger)getWidth;
-(NSTimeInterval)getTime;

@end

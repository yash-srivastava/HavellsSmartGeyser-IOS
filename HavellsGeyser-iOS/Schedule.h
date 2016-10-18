//
//  Schedule.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 03/10/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

@property(strong,atomic) NSString *day,*time,*duration,*temperature,*scheduleId;
@end

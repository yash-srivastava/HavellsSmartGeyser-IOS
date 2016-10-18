//
//  GeyserCommands.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeyserCommands : NSObject

+(id) sharedInstance;
-(NSMutableString *) hexStringToDecimalString:(NSString *) str;
- (NSMutableData *) hexStringToData:(NSString *) string;
-(NSMutableString *) stringToHexString:(NSString *) str;
-(void) toggleSwitch:(unsigned int) op duration:(unsigned int) dur temperature:(unsigned int) temp;

-(void) setWifiParams:(NSString *) ssid auth:(unsigned int)auth encryption:(unsigned int) enc passphrase:(NSString *)password;

- (void) setCurrentTime;

- (void) getCurrentTime;

-(void) addSchedulue:(int) day id:(int) scheduleId startTime:(NSString *) startTime duration:(int) dur temperature:(int) temp;

-(void) deleteSchedule:(int) day scheduleId:(int) scheduleId;

-(void) getSchedulue:(int) day;
@end

//
//  TCPClient.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"

@protocol TCPClientDelegate <NSObject>
- (void) connectionState:(NSString *) state;
- (void) currentTimeChanged:(NSString *) currTime;
- (void) schedulesUpdated:(Schedule *) schedule;
- (void) scheduleDeleted;
@end

@interface TCPClient : NSObject<NSStreamDelegate>

+(id) sharedInstance;
@property(strong,nonatomic) id<TCPClientDelegate> tcpDelegate;

@property(strong,nonatomic) NSInputStream   *inputStream;
@property(strong,nonatomic) NSOutputStream  *outputStream;

-(void) connectToSocket:(NSString *) ipAddr;
-(void) disconnectFromSocket;
-(BOOL) isConnected;
- (void) sendCommand:(NSMutableData *) command;

@property(strong,atomic) NSString * ONPacket,*OFFPacket, *switchFlag;
@property(strong,atomic) NSString * accessPoint;
@property(strong,atomic) NSMutableArray<Schedule *> *foundSchedules;

@property(strong,atomic) NSString * connectionFlag;

@end

//
//  TCPClient.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "TCPClient.h"
#import "GeyserCommands.h"
#import "Schedule.h"

#define ONOFF_PACKET_TYPE @"1000"
#define SCHEDULE_PACKET_TYPE @"1001"
#define CURRENT_TIME_PACKET_TYPE @"1002"
#define ROUTE_CONFIG_PACKET_TYPE @"1003"
#define SERVER_PARAM_PACKET_TYPE @"1004"
#define RESET_PACKET_TYPE @"1005"
#define GET_CURRENT_STATUS_PACKET_TYPE @"2000"
#define GET_SCHEDULE_PACKET_TYPE @"2001"
#define GET_CURR_SCHEDULE_PACKET_TYPE @"2002"


@implementation TCPClient


+ (id)sharedInstance
{
    static TCPClient *client = nil;
    if(client==nil){
    
        client = [[TCPClient alloc]init];
    }
    
//    if((client.connectionFlag == nil) || ![client.connectionFlag isEqualToString:@"Connected"])
//        [client connectToSocket];
    return client;
}

- (id)init
{
    self = [super init];
    if(self){
        _foundSchedules = [[NSMutableArray<Schedule *> alloc] init];
        _ONPacket = @"7E000F313233343536313233341000010020";
        _OFFPacket= @"7E000F313233343536313233341000000019";
        
        _switchFlag = @"OFF";
//        [self connectToSocket];
        
    }
    
    return self;
}

-(void) connectToSocket:(NSString *) ipAddr
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddr, 8000, &readStream, &writeStream);
//    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.101", 8000, &readStream, &writeStream);
//    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"224.0.0.251", 8000, &readStream, &writeStream);
    _inputStream =  (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
}

-(void) disconnectFromSocket
{
    
    [_inputStream close];
    [_outputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [_outputStream setDelegate:nil];
    _inputStream = nil;
    _outputStream = nil;
//    [_inputStream setDelegate:nil];
//    [_outputStream setDelegate:nil];
//    
//    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    
//    [_inputStream close];
//    [_outputStream close];
}

-(BOOL) isConnected
{
    if(_connectionFlag == nil) return NO;
    if([_connectionFlag isEqualToString:@"Connected"]) return YES;
    else return NO;
    
}
-(void) processBytes
{
    uint8_t buffer[10240];
    int len;
    
    while ([_inputStream hasBytesAvailable]) {
        len = [_inputStream read:buffer maxLength:sizeof(buffer)];
        if (len > 0) {
            NSData *data = [[NSData alloc] initWithBytes:buffer length:len];
            NSString *hexStr = [[NSString stringWithFormat:@"%@",data] capitalizedString];
            for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
                hexStr = [hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
            NSMutableString *temp = [[NSMutableString alloc]init];
            
            
            //Separating by delimiter
            NSArray *parts = [hexStr componentsSeparatedByString:@"7E"];
            for(int i=0;i<[parts count];i++){
                NSLog(@"%@",[NSString stringWithFormat:@"7E%@",parts[i]]);
                if([parts[i] isEqualToString:@"50454E44494E47"] || [parts[i] isEqualToString:@"7E"] || [parts[i] isEqualToString:@""]) continue;
                
                NSString * dataPacket = [parts[i] substringFromIndex:24];
                NSString * packetType = [dataPacket substringWithRange:NSMakeRange(0, 4)];
                NSString *status = [dataPacket substringWithRange:NSMakeRange(4, 2)];
                
                //If not successfull
                if(![status isEqualToString:@"00"]) continue;
                
                if([packetType isEqualToString:ONOFF_PACKET_TYPE]){
                    
                }else if([packetType isEqualToString:SCHEDULE_PACKET_TYPE]){
                    NSLog(@"Deleted successfully");
                    if([self.tcpDelegate respondsToSelector:@selector(scheduleDeleted)])
                        [self.tcpDelegate scheduleDeleted];
                    
                }else if([packetType isEqualToString:CURRENT_TIME_PACKET_TYPE]){
                    if ([self.tcpDelegate respondsToSelector:@selector(currentTimeChanged:)]){
                        
                        
                        unsigned long long dateValue;
                        //Time
                        NSString *coreData = [dataPacket substringFromIndex:6];
                        NSMutableString * dateString = [[GeyserCommands sharedInstance]hexStringToDecimalString:coreData];
                        
                        unsigned int year,month,day,hour,minute,second;
                        year  =[[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
                        month = [[dateString substringWithRange:NSMakeRange(4, 2)] intValue];
                        day = [[dateString substringWithRange:NSMakeRange(6, 2)] intValue];
                        hour = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
                        minute = [[dateString substringWithRange:NSMakeRange(10, 2)] intValue];
                        second = [[dateString substringWithRange:NSMakeRange(12, 2)] intValue];
                        [self.tcpDelegate currentTimeChanged:[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d",year,month,day,hour,minute,second]];
                        
                    }
                }else if([packetType isEqualToString:ROUTE_CONFIG_PACKET_TYPE]){
                    
                }else if([packetType isEqualToString:SERVER_PARAM_PACKET_TYPE]){
                    
                }else if([packetType isEqualToString:RESET_PACKET_TYPE]){
                    
                }else if([packetType isEqualToString:GET_SCHEDULE_PACKET_TYPE]){
                    if([dataPacket length] < 72) return;
                    NSString *daySchedule = [dataPacket substringFromIndex:6];
                    int day = [[NSString stringWithFormat:@"%@",[daySchedule substringWithRange:NSMakeRange(0, 2)]] intValue];
                    
                    
                    NSString *schedulesString = [daySchedule substringFromIndex:2];
                    int noOfChars = 14; //For each schedule
                    for(int i=1;i<=5;i++){
                        NSString *individualSchedule = [schedulesString substringWithRange:NSMakeRange((i-1)*noOfChars, noOfChars)];
                        NSString *timeString = [[GeyserCommands sharedInstance] hexStringToDecimalString:[individualSchedule substringWithRange:NSMakeRange(2, 8)]];
                        NSString * durString = [[GeyserCommands sharedInstance] hexStringToDecimalString:[individualSchedule substringWithRange:NSMakeRange(10, 2)]];
                        NSString * tempString = [[GeyserCommands sharedInstance] hexStringToDecimalString:[individualSchedule substringWithRange:NSMakeRange(12, 2)]];
                        
                        unsigned int dur,temp;
                        
                        NSScanner *scanner = [NSScanner scannerWithString:[individualSchedule substringWithRange:NSMakeRange(10, 2)]];
                        
                        [scanner scanHexInt:&dur];
                        
                        scanner = [NSScanner scannerWithString:[individualSchedule substringWithRange:NSMakeRange(12, 2)]];
                        
                        [scanner scanHexInt:&temp];
                        
                        NSLog(@"%d %@ %d %d",day,timeString,dur,temp);
                        
                        Schedule *schedule = [[Schedule alloc]init];
                        switch (day) {
                            case 1: schedule.day = @"Mon"; break;
                            case 2: schedule.day = @"Tue"; break;
                            case 3: schedule.day = @"Wed"; break;
                            case 4: schedule.day = @"Thu"; break;
                            case 5: schedule.day = @"Fri"; break;
                            case 6: schedule.day = @"Sat"; break;
                            case 7: schedule.day = @"Sun"; break;
                            default:
                                break;
                        }
                        if([timeString length]==4){
                            schedule.time  = [NSString stringWithFormat:@"From: %@:%@",[timeString substringWithRange:NSMakeRange(0, 2)],[timeString substringWithRange:NSMakeRange(2, 2)]];
                            schedule.duration = [NSString stringWithFormat:@"Dur: %d",dur];
                            schedule.temperature = [NSString stringWithFormat:@"Temp: %d",temp];
                            
                            schedule.scheduleId = [NSString stringWithFormat:@"%d",i];
                            if([self.tcpDelegate respondsToSelector:@selector(schedulesUpdated:)])
                                [self.tcpDelegate schedulesUpdated:schedule];
                        }                        
                        
                    }
                    
                }else if([packetType isEqualToString:GET_CURR_SCHEDULE_PACKET_TYPE]){
                    
                }else if([packetType isEqualToString:GET_CURRENT_STATUS_PACKET_TYPE]){
                    
                }
                
                
            }
            
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            
            _connectionFlag = @"Connected";
            [self.tcpDelegate connectionState:@"Connection Established"];
            
//            [NSTimer scheduledTimerWithTimeInterval:20.0 target:[SolarCommands sharedInstance] selector:NSSelectorFromString(@"sendPair") userInfo:nil repeats:YES];
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == _inputStream) {
                [self processBytes];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            [self.tcpDelegate connectionState:@"Connection Failure"];
            _connectionFlag = @"Connected Failure";
            [self disconnectFromSocket];
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"Event ended");
            [self.tcpDelegate connectionState:@"Disconnected"];
            _connectionFlag = @"Disconnected";
            [self disconnectFromSocket];
            break;
            
        default:
            if (aStream == _inputStream) {
                [self processBytes];

            }else if(aStream == _outputStream){
            NSLog(@"Unknown event");
                [self processBytes];
            }
    }
}


- (void) sendCommand:(NSMutableData *) command
{
    [_outputStream write:[command bytes] maxLength:[command length]];
}
@end

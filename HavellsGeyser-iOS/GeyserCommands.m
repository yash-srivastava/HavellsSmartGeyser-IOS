//
//  GeyserCommands.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "GeyserCommands.h"
#import "TCPClient.h"

#define DELIMITER @"7E"
#define ONOFF_PACKET_TYPE @"1000"
#define SCHEDULE_PACKET_TYPE @"1001"
#define CURRENT_TIME_PACKET_TYPE @"1002"
#define ROUTE_CONFIG_PACKET_TYPE @"1003"
#define SERVER_PARAM_PACKET_TYPE @"1004"
#define RESET_PACKET_TYPE @"1005"
#define GET_CURRENT_STATUS_PACKET_TYPE @"2000"
#define GET_SCHEDULE_PACKET_TYPE @"2001"
#define GET_CURR_SCHEDULE_PACKET_TYPE @"2002"

#define MAC_ADDRESS @"9AE235F6E996"

@interface GeyserCommands()
 
@end

@implementation GeyserCommands


+ (id)sharedInstance
{
    static GeyserCommands *client = nil;
    if(client==nil){
        
        client = [[GeyserCommands alloc]init];
    }
    return client;
}

- (NSMutableData *) hexStringToData:(NSString *) string
{
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([string length] / 2); i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}

-(NSMutableString *) hexStringToDecimalString:(NSString *) str
{
    NSMutableString *decimalString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [str length])
    {
        NSString * hexChar = [str substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [decimalString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return decimalString;
}

-(NSMutableString *) stringToHexString:(NSString *) str
{
    NSMutableString * hexStr = [NSMutableString stringWithFormat:@"%@",
                         [NSData dataWithBytes:[str cStringUsingEncoding:NSUTF8StringEncoding]
                                        length:strlen([str cStringUsingEncoding:NSUTF8StringEncoding])]];
    for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
        hexStr = (NSMutableString *)[hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
    
    
    
    
    return [hexStr capitalizedString];
}

-(NSString *) appendExtraBytes:(NSMutableString *)result length:(unsigned int) numBytes
{
    unsigned reqLength = 2 * numBytes;
    reqLength -= [result length];
    
    //Append the extra bytes
    for(int i=1;i<=reqLength;i++){
        [result appendString:@"0"];
    }
    
    NSLog(@"%@",result);
    return [result capitalizedString];
}

-(void) toggleSwitch:(unsigned int) op duration:(unsigned int) dur temperature:(unsigned int) temp
{
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 15,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:ONOFF_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",op] uppercaseString]];
    
    //Duration - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",dur] uppercaseString]];
    
    //Temperature - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",temp] uppercaseString]];
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];
}


- (void)setWifiParams:(NSString *)ssid auth:(unsigned int)auth encryption:(unsigned int)enc passphrase:(NSString *)password
{
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];

    unsigned int length = 111,seq = 1;
    
    
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:@"313233343536"];
    
    //Sequence Number - 4 bytes
//    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    [command appendString:@"31323334"];
    

    //Packet Type - 2 bytes
    [command appendString:ROUTE_CONFIG_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",0] uppercaseString]];
    
    //SSID - 32 bytes
    [command appendString:[self appendExtraBytes:[self stringToHexString:ssid] length:32]];
    
    //Authentication - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",auth] uppercaseString]];
    
    //Encryption - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",enc] uppercaseString]];
    
    //Passphrase -  64 bytes
    [command appendString:[self appendExtraBytes:[self stringToHexString:password] length:64]];
    
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];

}

- (void) setCurrentTime
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 27,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:CURRENT_TIME_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",0] uppercaseString]];
    
    NSString *timeString = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d",(int)[components year],(int)[components month],(int)[components day],(int)[components hour],(int)[components minute],(int)[components second]];
//    timeString =@"20160912065312";
    [command appendString:[self stringToHexString:timeString]];
    

    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];

}

- (void) getCurrentTime
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
    
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 27,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:CURRENT_TIME_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",1] uppercaseString]];
    
    NSString *timeString = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d",(int)[components year],(int)[components day],(int)[components month],(int)[components hour],(int)[components minute],(int)[components second]];
    [command appendString:[self stringToHexString:timeString]];
    
    
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];
    
}

-(void) addSchedulue:(int) day id:(unsigned int) scheduleId startTime:(NSString *) startTime duration:(unsigned int) dur temperature:(unsigned int) temp
{
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 21,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:SCHEDULE_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",1] uppercaseString]];
    
    //Day - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",day] uppercaseString]];
    
    //Schedule ID - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",scheduleId] uppercaseString]];
    
    //Start time - 4 bytes
    [command appendString:[[self stringToHexString:startTime]uppercaseString]];
    
    //Duration - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",dur] uppercaseString]];
    
    //Temperature - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",temp] uppercaseString]];
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];
}

-(void) deleteSchedule:(int) day scheduleId:(int) scheduleId
{
    
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 15,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:SCHEDULE_PACKET_TYPE];
    
    //Operation - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",0] uppercaseString]];
    
    //Day - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",day] uppercaseString]];
    
    //Schedule ID - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",scheduleId] uppercaseString]];
    
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];
}

-(void) getSchedulue:(int) day
{
    NSMutableString *command = [[NSMutableString alloc]initWithString:DELIMITER];
    unsigned int length = 13,seq = 1;
    //Packet length - 2 bytes
    [command appendString:[[NSString stringWithFormat:@"%04x",length] uppercaseString]];
    
    //Water Heater Id - 6 bytes
    [command appendString:[MAC_ADDRESS capitalizedString]];
    
    //Sequence Number - 4 bytes
    [command appendString:[[NSString stringWithFormat:@"%08x",seq] uppercaseString]];
    
    //Packet Type - 2 bytes
    [command appendString:GET_SCHEDULE_PACKET_TYPE];
    
    //Day - 1 byte
    [command appendString:[[NSString stringWithFormat:@"%02x",day] uppercaseString]];
    
    NSLog(@"%@",[command capitalizedString]);
    [[TCPClient sharedInstance] sendCommand:[self hexStringToData:[command capitalizedString]]];
    
    
}
@end

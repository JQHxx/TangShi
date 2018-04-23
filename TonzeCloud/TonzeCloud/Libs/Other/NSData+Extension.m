//
//  NSData+Extension.m
//  JinAnSecurity
//
//  Created by AllenKwok on 15/10/17.
//  Copyright © 2015年 JinAn. All rights reserved.
//

#import "NSData+Extension.h"

@implementation NSData (Extension)

+ (NSArray *)dataToByte:(NSData *)data{
    
    Byte *byte = (Byte *)[data bytes];
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    for (int i = 0; i<data.length; i++) {
        
        [mArr addObject:@(byte[i])];
        
    }
    
    return mArr;
}

+ (NSData*)stringToData:(NSString *)hexString {
    
    NSUInteger len = hexString.length / 2;
    const char *hexCode = [hexString UTF8String];
    char * bytes = (char *)malloc(len);
    
    char *pos = (char *)hexCode;
    for (NSUInteger i = 0; i < hexString.length / 2; i++) {
        sscanf(pos, "%2hhx", &bytes[i]);
        pos += 2 * sizeof(char);
    }
    
    NSData * data = [[NSData alloc] initWithBytes:bytes length:len];
    
    free(bytes);
    return data;
}

+ (instancetype)dataWithHexString:(NSString *)hexString {
    NSString *strWithoutSpace = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSData stringToData:strWithoutSpace];
}

- (NSString *)hexString {
    NSMutableString *string = @"".mutableCopy;
    const Byte *bytes = [self bytes];
    for (int i=0; i<self.length; i++) {
        [string appendFormat:@"%02X ", bytes[i]];
    }
    return string;
}

+(NSData*)nsstringToHex:(NSString*)string{
    
    const char *buf = [string UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        unsigned long len = strlen(buf);
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(buf[i])  )
            {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp)length:1];
            }
            else
            {
                break;
            }
        }
    }
    
    
    return data;
}

@end

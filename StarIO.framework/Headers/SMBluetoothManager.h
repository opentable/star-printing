//
//  PrinterManager.h
//  BluetoothSettingUtility
//
//  Created by u3237 on 13/03/06.
//  Copyright (c) 2013年 Star Micronics co.,ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMPort;

typedef enum _SMDeviceType {
    SMDeviceTypeDesktopPrinter,
    SMDeviceTypePortablePrinter
} SMDeviceType;

typedef enum _SMBluetoothSecurity {
    SMBluetoothSecuritySSP,
    SMBluetoothSecurityPINcode
} SMBluetoothSecurity;

typedef enum _SecuritySetting {
    PinCode,
    SSP
} SecuritySetting;

@interface SMBluetoothManager : NSObject {
    SMPort *port;
}

@property(retain, readonly) NSString *portName;
@property(assign, readonly) SMDeviceType deviceType;
@property(assign, readonly) BOOL opened;

@property(retain) NSString *deviceName;
@property(retain) NSString *iOSPortName;
@property(assign) BOOL autoConnect;
@property(assign) SMBluetoothSecurity security;
@property(retain) NSString *pinCode;

#pragma mark Public API

- (id)initWithPortName:(NSString *)portName deviceType:(SMDeviceType)deviceType;
- (BOOL)open;
- (BOOL)loadSetting;
- (BOOL)apply;
- (void)close;

@end

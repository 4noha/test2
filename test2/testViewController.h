//
//  testViewController.h
//  test2
//
//  Created by 野秋拓也 on 2014/03/09.
//  Copyright (c) 2014年 nokkii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "FMDatabase.h"

@interface testViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextInput;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextInput;
@property (weak, nonatomic) IBOutlet UISwitch *startToggle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textInput;
- (void) initCentral;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
@end

bool isStart;
int gettable;
double longitude;
double latitude;
NSTimer *tm;
NSDateFormatter* formatter;
CBCentralManager *mCentralManager;

CLLocationManager *manager;
CLLocationManager *locationManager;
CLBeaconRegion *beaconRegion;
CLBeaconRegion *region;
NSUUID *proximityUUID;

FMDatabase *db;
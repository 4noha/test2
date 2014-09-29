//
//  testViewController.m
//  test2
//
//  Created by 野秋拓也 on 2014/03/09.
//  Copyright (c) 2014年 nokkii. All rights reserved.
//

#import "testViewController.h"

@interface testViewController () <CLLocationManagerDelegate>

@end

@implementation testViewController

- (void) initCentral
{
    /*mCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    NSMutableArray* services = [NSMutableArray array];
    [services addObject:nil];
    
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [mCentralManager scanForPeripheralsWithServices:nil options:options];*/
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral: %@", peripheral);
}
// ユーザの位置情報の許可状態を確認するメソッド
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        [locationManager startMonitoringForRegion: beaconRegion];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        [locationManager startMonitoringForRegion: beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}
- (void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    if (1 <= gettable){
        NSDate* currentDate;
        self.textView.text = @"iBeacons Status\n";
        NSString *sql=@"insert into wifi (time,essid,bssid,lat,lon,rssi) values (?,?,?,?,?,?)";
        [db open];
        [db beginTransaction];
        
        for (CLBeacon* beacon in beacons) {
            currentDate = [NSDate date];
            self.textView.text = [NSString stringWithFormat:@"%@Mejor:%@ Minor:%@ RSSI:%ld[dBm]\n",
                                  self.textView.text, beacon.major.stringValue,
                                  beacon.minor.stringValue, (long)beacon.rssi];
            [db executeUpdate:sql,
             [formatter stringFromDate:currentDate],
             [NSString stringWithFormat:@"%@,%@",beacon.major.stringValue,beacon.minor.stringValue],
             [NSString stringWithFormat:@"%@,%@",beacon.major.stringValue,beacon.minor.stringValue],
             [NSNumber numberWithDouble:latitude],
             [NSNumber numberWithDouble:longitude],
             [NSNumber numberWithLong:beacon.rssi]];
            [db commit];
        }
        
        self.textView.text = [NSString stringWithFormat:@"%@Now Recording!\n", self.textView.text];
        
        [db close];
        
        gettable=0;
    } else {
        self.textView.text = @"iBeacons Status\n";
        for (CLBeacon* beacon in beacons) {
            self.textView.text = [NSString stringWithFormat:@"%@Mejor:%@ Minor:%@ RSSI:%ld[dBm]\n",
                                  self.textView.text, beacon.major.stringValue,
                                  beacon.minor.stringValue, (long)beacon.rssi];
        }
        self.textView.text = [NSString stringWithFormat:@"%@Not Recording\n", self.textView.text];
    }
}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [locationManager requestStateForRegion:beaconRegion];
    [locationManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isStart = false;
    gettable = 0;
    [tm invalidate];
    self.textView.text = @"iBeacons Status";
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    //DBファイルのパス
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *dir   = [paths objectAtIndex:0];
    //DBファイルがあるかどうか確認   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[dir stringByAppendingPathComponent:@"file.db"]])
    {
        //なければ新規作成
        db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
        NSString *sql = @"CREATE TABLE wifi (id INTEGER PRIMARY KEY AUTOINCREMENT,time TEXT,essid TEXT,bssid TEXT,lat REAL,lon REAL,rssi INTEGER);";
        [db open]; //DB開く
        [db executeUpdate:sql]; //SQL実行
        [db close]; //DB閉じる
    } else {
        db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"file.db"]];
    }

    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        
        proximityUUID = [[NSUUID alloc] initWithUUIDString:@"00000000-055E-1001-B000-001C4D736D7E"];
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                        identifier:@"jp.nokkii.test2"];
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
            // 位置情報の取得許可を求めるメソッド
            [locationManager requestAlwaysAuthorization];
        } else {
            // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
            [locationManager startMonitoringForRegion: beaconRegion];
        }
        //beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:nil identifier:nil];
        [locationManager startMonitoringForRegion:beaconRegion];
    }
}

- (IBAction)toggleChange:(id)sender {
    if (!isStart)
    {
        isStart = true;
        [self initCentral];
        if (self.textInput.text.floatValue <= 1.0f){
            tm =
            [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                             target:self selector:@selector(hoge:)
                                           userInfo:nil repeats:YES
             ];
        } else {
            tm =
            [NSTimer scheduledTimerWithTimeInterval: self.textInput.text.floatValue / 1.0f
                                             target:self selector:@selector(hoge:)
                                           userInfo:nil repeats:YES
             ];
        }
        longitude = self.longitudeTextInput.text.doubleValue;
        latitude = self.latitudeTextInput.text.doubleValue;
        [tm fire];
    } else {
        isStart = false;
        [tm invalidate];
    }
}

-(void)hoge:(NSTimer*)timer{
    if (isStart)
    {
        gettable++;
    }
}

@end

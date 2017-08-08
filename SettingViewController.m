//
//  SettingViewController.m
//
//  Created by Rajeev on 16/05/17.
//

#import "SettingViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>

@interface SettingViewController ()

@property (nonatomic, weak) IBOutlet UITableView *customTableV;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkDeviceHardware];
}

-(void)checkDeviceHardware {
    
    // Get iOS Device name
    NSString *deviceName = [self deviceName];   // ex: UIDevice4GiPhone
    
    // Get iOS device version
    NSString *deviceVersion = [[UIDevice currentDevice]systemVersion]; // ex: @"iPhone 4G"
    NSLog(@"Device name = %@ and Device Version = %@", deviceName, deviceVersion);
    
    // Get iPhone carrier name
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *string = [carrier carrierName];
    NSLog(@"Carrier name is %@", string);
    
    // Get iOS device memory information
    [self freeDiskspace];
    
    // Get iOS Device Back camera resolution
    [self getResolutionForCameraWith:AVCaptureDevicePositionBack AndCameraType:@"Back Camera"];
    
    // Get iOS Device Front camera resolution

    [self getResolutionForCameraWith:AVCaptureDevicePositionFront AndCameraType:@"Front Camera"];
    
    // Get iOS Device Video resolution

    [self getResolutionForCameraWith:AVCaptureDevicePositionFront AndCameraType:@"Video"];
    
    // Get iOS Device color
    UIDevice *device = [UIDevice currentDevice];
    SEL selector = NSSelectorFromString(@"deviceInfoForKey:");
    if (![device respondsToSelector:selector]) {
        selector = NSSelectorFromString(@"_deviceInfoForKey:");
    }
    if ([device respondsToSelector:selector]) {
        NSLog(@"DeviceColor: %@ DeviceEnclosureColor: %@", [device performSelector:selector withObject:@"DeviceColor"], [device performSelector:selector withObject:@"DeviceEnclosureColor"]);
    }
}

- (uint64_t)freeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", (((totalSpace/1024ll)/1024ll)/1024), ((totalFreeSpace/1024ll)/1024ll));
        totalSpace = totalSpace/1024;
        totalFreeSpace = totalFreeSpace/1024;
        
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalFreeSpace;
}

-(NSString*) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

-(AVCaptureDevice*)cameraWith:(AVCaptureDevicePosition)postition {
    
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in  devices){
        if ([device position] == postition){
            return device ;
        }
    }
    
    return nil;
}

-(void)getResolutionForCameraWith:(AVCaptureDevicePosition)position AndCameraType:(NSString*)cameraType {
    
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    if ([cameraType isEqualToString:@"Video"]) {
        session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    else {
        session.sessionPreset  = AVCaptureSessionPresetPhoto;
    }
    
    //Get device
    
    AVCaptureDevice *device = [self cameraWith:position];
    NSError *error;
    if (device){
        AVCaptureDeviceInput *input  = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
        
        //add input to session
        [session addInput:input];
        
        //create output
        AVCaptureStillImageOutput *output =  [[AVCaptureStillImageOutput alloc]init];
        [session addOutput:output];
        
        //get resolution
       CMVideoDimensions resolution = device.activeFormat.highResolutionStillImageDimensions;
        NSLog(@"Resolution height == %d and width == %d",resolution.height, resolution.width);
        
        float totalResolution = resolution.height * resolution.width;
        float cameraMegapixel = totalResolution/1000000;
        NSLog(@"Camera megapixel of %@ is %0.0f",cameraType,cameraMegapixel);
    }
}

@end

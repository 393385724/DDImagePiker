//
//  DDAVCamera.m
//  FitRunning
//
//  Created by lilingang on 15/9/26.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "DDAVCamera.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>

@interface DDAVCamera ()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, strong) AVCaptureDevice             *captureDevice;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession            *session;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong) AVCaptureDeviceInput        *deviceInput;
//照片输出流对象
@property (nonatomic, strong) AVCaptureStillImageOutput   *stillImageOutput;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong) AVCaptureVideoPreviewLayer  *videoPreviewLayer;

@property (nonatomic, weak) UIView *view;

@end

@implementation DDAVCamera

#pragma mark -
#pragma mark  LifeCycle

- (instancetype)initWithSuperView:(UIView *)superView
                   cameraPosition:(AVCaptureDevicePosition)cameraPosition{
    self = [super init];
    if (self) {
        self.view = superView;
        
        self.sessionQueue = dispatch_queue_create("AVCapture session queue", DISPATCH_QUEUE_SERIAL);
        
        // Grab the back-facing or front-facing camera
        self.captureDevice = [self cameraWithPosition:cameraPosition];
        self.session = [[AVCaptureSession alloc] init];
        [self.session beginConfiguration];
        
        self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
        if ([self.session canAddInput:self.deviceInput]) {
            [self.session addInput:self.deviceInput];
            
            self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            [self.stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]];
            
            if ([self.session canAddOutput:self.stillImageOutput]) {
                [self.session addOutput:self.stillImageOutput];
                
                self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
                self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                self.videoPreviewLayer.frame = superView.bounds;
                [superView.layer addSublayer:self.videoPreviewLayer];
            }
        }
        //AVCaptureSessionPresetPhoto the AVCaptureVideoPreviewLayer respect the 3/4 ration of iPhone camera
        [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
        [self.session commitConfiguration];
        
        self.flashMode = AVCaptureFlashModeOff;
        self.focusMode = AVCaptureFocusModeAutoFocus;
        
    }
    return self;
}

#pragma mark -
#pragma mark  control

+ (void)requestAccessCompletionHandler:(void (^)(BOOL granted))handler{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        if (handler) {
            handler(NO);
        }
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:handler];
    }
    else if (authStatus == AVAuthorizationStatusAuthorized){
        if (handler) {
            handler(YES);
        }
    }
}


- (void)switchDevicePosition{
    AVCaptureDevicePosition currentCameraPosition = [[self.deviceInput device] position];
    if (currentCameraPosition == AVCaptureDevicePositionBack){
        currentCameraPosition = AVCaptureDevicePositionFront;
    } else {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    self.captureDevice = [self cameraWithPosition:currentCameraPosition];
    
    [self.session beginConfiguration];
    [self.session removeInput:self.deviceInput];
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    [self.session commitConfiguration];
}

#pragma mark -
#pragma mark  Public

- (void)startRunning{
    if(![self.session isRunning]){
        [self.session startRunning];
    }
}

- (void)focusInPoint:(CGPoint)devicePoint{
    devicePoint = [self convertToPointOfInterestFromViewCoordinates:devicePoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)takePicture{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    if ( nil == videoConnection) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"AVCaptureConnection 获取失败" code:0 userInfo:nil];
            [self.delegate camera:self didFailWithError:error];
        }
        NSLog(@"AVCaptureConnection 获取失败");
        return;
    }
    [videoConnection setVideoScaleAndCropFactor:1.0];
    
    __weak __typeof(&*self)weakSelf = self;
    //get UIImage
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (!imageSampleBuffer || error) {
             if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(camera:didFailWithError:)]) {
                 NSError *error = [NSError errorWithDomain:@"!imageSampleBuffer || error" code:0 userInfo:nil];
                 [weakSelf.delegate camera:weakSelf didFailWithError:error];
             }
             return;
         }
         [weakSelf stopRunning];
         
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *originImage = [UIImage imageWithData:imageData];
         originImage = [originImage ddImageRotatedWithOrientation];
         
         CGRect rect = CGRectMake(0, 0, originImage.size.width, originImage.size.width);
         CGImageRef imref = CGImageCreateWithImageInRect(originImage.CGImage, rect);
         UIImage *newSubImage = [UIImage imageWithCGImage:imref];
         CGImageRelease(imref);
         
         if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(camera:didFinishPickingMediaWithInfo:)]) {
             NSDictionary *imageInfo = @{UIImagePickerControllerEditedImage:newSubImage,
                                         UIImagePickerControllerOriginalImage:originImage,
                                         UIImagePickerControllerCropRect:NSStringFromCGRect(rect)};
             if (exifAttachments) {
                 NSMutableDictionary *tempDict = [imageInfo mutableCopy];
                 [tempDict setValue:(__bridge NSDictionary*)exifAttachments forKey:UIImagePickerControllerMediaType];
                 imageInfo = [tempDict copy];
             }
             [weakSelf.delegate camera:weakSelf didFinishPickingMediaWithInfo:imageInfo];
         }
     }];
}

- (void)stopRunning{
    if([self.session isRunning]){
        [self.session stopRunning];
    }
}


#pragma mark -
#pragma mark  Private

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

/**
 *  外部的point转换为camera需要的point(外部point/相机页面的frame)
 *
 *  @param viewCoordinates 外部的point
 *
 *  @return 相对位置的point
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = self.videoPreviewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.videoPreviewLayer;
    
    if([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[self.session.inputs lastObject]ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevice *device = [self.deviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]){
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]){
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            } if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]){
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else{
            NSLog(@"%@", error);
        }
    });
}

#pragma mark -
#pragma mark Accessor

-(AVCaptureFocusMode)focusMode{
    return self.captureDevice.focusMode;
}

-(void)setFocusMode:(AVCaptureFocusMode)focusMode{
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isFocusModeSupported:focusMode]) {
            self.captureDevice.focusMode = focusMode;
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(AVCaptureFlashMode)flashMode{
    return self.captureDevice.flashMode;
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode{
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isFlashModeSupported:flashMode]) {
            self.captureDevice.flashMode = flashMode;
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(AVCaptureExposureMode)exposureMode{
    return self.captureDevice.exposureMode;
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isExposureModeSupported:exposureMode]) {
            self.captureDevice.exposureMode = exposureMode;
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(AVCaptureWhiteBalanceMode)whiteBalanceMode{
    return self.captureDevice.whiteBalanceMode;
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode{
    if ([self.captureDevice lockForConfiguration:nil]) {
        if ([self.captureDevice isWhiteBalanceModeSupported:whiteBalanceMode]) {
            self.captureDevice.whiteBalanceMode = whiteBalanceMode;
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(BOOL)hasFlash{
    return self.captureDevice.hasFlash;
}

-(BOOL)hasMoreDevice{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1;
}

@end

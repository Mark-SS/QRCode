//
//  ViewController.m
//  QRCode
//
//  Created by gongliang on 14/11/3.
//  Copyright (c) 2014年 AB. All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;

@property (weak, nonatomic) IBOutlet UIView *qrView;

@end

@implementation ViewController

- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [AVCaptureSession new];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self beginCamera];
    [self.session startRunning];
}

- (void)beginCamera {
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device
                                                                         error:&error];
    if (error) {
        return ;
    }
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    self.layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layer.frame = self.qrView.bounds;
    [self.qrView.layer insertSublayer:self.layer atIndex:0];
    AVCaptureMetadataOutput *outPut = [AVCaptureMetadataOutput new];
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([self.session canAddOutput:outPut]) {
        [self.session addOutput:outPut];
        outPut.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    NSString *qrCodeString;
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        qrCodeString = metadataObject.stringValue;
    }
    
    [self.session stopRunning];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"二维码"
                                                        message:qrCodeString
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确认", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

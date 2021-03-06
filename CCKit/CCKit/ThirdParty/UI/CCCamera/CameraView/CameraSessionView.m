//
//  CACameraSessionDelegate.h
//  CCKit
//
// Copyright (c) 2015 CC ( https://github.com/gmaukh4517/CCKit )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CameraSessionView.h"
#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

//Custom UI classes
#import "CameraShutterButton.h"
#import "CameraToggleButton.h"
#import "CameraFlashButton.h"
#import "CameraDismissButton.h"
#import "CameraFocalReticule.h"
#import "Constants.h"

#import "CCCameraPreview.h"
#import <CoreMotion/CMMotionManager.h>
#import "CCLanguage.h"

@interface CameraSessionView () <CaptureSessionManagerDelegate> {
    //Size of the UI elements variables
    CGSize shutterButtonSize;
    CGSize topBarSize;
    CGSize barButtonItemSize;

    //Variable vith the current camera being used (Rear/Front)
    CameraType cameraBeingUsed;
}

//Primative Properties
@property (readwrite) BOOL animationInProgress;

//Object References
@property (nonatomic, strong) CaptureSessionManager *captureManager;
@property (nonatomic, strong) CameraShutterButton *cameraShutter;
@property (nonatomic, strong) CameraToggleButton *cameraToggle;
@property (nonatomic, strong) CameraFlashButton *cameraFlash;
@property (nonatomic, strong) CameraDismissButton *cameraDismiss;
@property (nonatomic, strong) CameraFocalReticule *focalReticule;
@property (nonatomic, strong) UIView *topBarView;

//Temporary/Diagnostic properties
@property (nonatomic, strong) UILabel *ISOLabel, *apertureLabel, *shutterSpeedLabel;

@property (nonatomic, strong) CCCameraPreview *cameraPreView;

@property (nonatomic, strong) UIView *preViewPhoto;

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation CameraSessionView

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _animationInProgress = NO;
    [self setupCaptureManager:RearFacingCamera];
    cameraBeingUsed = RearFacingCamera;
    [self composeInterface];

    [[_captureManager captureSession] startRunning];
    //    [self.view addSubview:self.preViewPhoto];
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];

                                            }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1 / 15.0;
    }
    return _motionManager;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    NSNumber *value;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0)
            value = [NSNumber numberWithInt:UIDeviceOrientationPortraitUpsideDown];
        else
            value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    } else {
        if (x >= 0)
            value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
        else
            value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
    }

    if (value)
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

#pragma mark - Setup

- (void)setupCaptureManager:(CameraType)camera
{
    // remove existing input
    AVCaptureInput *currentCameraInput = [self.captureManager.captureSession.inputs objectAtIndex:0];
    [self.captureManager.captureSession removeInput:currentCameraInput];

    _captureManager = nil;

    //Create and configure 'CaptureSessionManager' object
    _captureManager = [CaptureSessionManager new];

    // indicate that some changes will be made to the session
    [self.captureManager.captureSession beginConfiguration];

    if (_captureManager) {
        //Configure
        [_captureManager setDelegate:self];
        [_captureManager initiateCaptureSessionForCamera:camera];
        [_captureManager addStillImageOutput];
        [_captureManager addVideoPreviewLayer];
        [self.captureManager.captureSession commitConfiguration];

        //Preview Layer setup
        CGRect layerRect = self.view.layer.bounds;
        [_captureManager.previewLayer setBounds:layerRect];
        [_captureManager.previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];

        //Apply animation effect to the camera's preview layer
        CATransition *applicationLoadViewIn = [CATransition animation];
        [applicationLoadViewIn setDuration:0.6];
        [applicationLoadViewIn setType:kCATransitionReveal];
        [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [_captureManager.previewLayer addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];

        //Add to self.view's layer
        [self.view.layer addSublayer:_captureManager.previewLayer];
    }
}

- (void)composeInterface
{
    //Adding notifier for orientation changes
    //    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

    //Define adaptable sizing variables for UI elements to the right device family (iPhone or iPad)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //Declare the sizing of the UI elements for iPad
        shutterButtonSize = CGSizeMake(self.view.bounds.size.width * 0.1, self.view.bounds.size.width * 0.1);
        topBarSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 0.06);
        barButtonItemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height * 0.04, [[UIScreen mainScreen] bounds].size.height * 0.04);
    } else {
        //Declare the sizing of the UI elements for iPhone
        shutterButtonSize = CGSizeMake(self.view.bounds.size.width * 0.21, self.view.bounds.size.width * 0.21);
        topBarSize = CGSizeMake(self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height * 0.07);
        barButtonItemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height * 0.05, [[UIScreen mainScreen] bounds].size.height * 0.05);
    }


    //Create shutter button
    _cameraShutter = [CameraShutterButton new];

    if (_captureManager) {
        //Button Visual attribution
        _cameraShutter.frame = (CGRect){0, 0, shutterButtonSize};
        _cameraShutter.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 0.875);
        _cameraShutter.tag = ShutterButtonTag;
        _cameraShutter.backgroundColor = [UIColor clearColor];

        //Button target
        [_cameraShutter addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cameraShutter];
    }

    //Create the top bar and add the buttons to it
    _topBarView = [UIView new];

    if (_topBarView) {
        //Setup visual attribution for bar
        _topBarView.frame = (CGRect){0, 0, topBarSize};
        //        _topBarView.backgroundColor = [UIColor colorWithRed: 0.176 green: 0.478 blue: 0.529 alpha: 0.64];
        [self.view addSubview:_topBarView];

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _topBarView.frame;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor,
                                                    (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor,
                                                    (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.01].CGColor, nil];
        [_topBarView.layer insertSublayer:gradient atIndex:0];

        //Add the camera dismiss button
        _cameraDismiss = [CameraDismissButton new];
        if (_cameraDismiss) {
            _cameraDismiss.frame = (CGRect){10, 10, barButtonItemSize};
            _cameraDismiss.tag = DismissButtonTag;
            [_topBarView addSubview:_cameraDismiss];
        }

        //Add the flash button
        _cameraFlash = [CameraFlashButton new];
        if (_cameraFlash) {
            _cameraFlash.frame = (CGRect){topBarSize.width - barButtonItemSize.width - barButtonItemSize.width - 40, 10, barButtonItemSize};
            _cameraFlash.tag = FlashButtonTag;
            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) [_topBarView addSubview:_cameraFlash];
        }

        //Add the camera toggle button
        _cameraToggle = [CameraToggleButton new];
        if (_cameraToggle) {
            _cameraToggle.frame = (CGRect){topBarSize.width - barButtonItemSize.width - 20, 10, barButtonItemSize};
            _cameraToggle.tag = ToggleButtonTag;
            [_topBarView addSubview:_cameraToggle];
        }

        //Attribute and configure all buttons in the bar's subview
        for (UIButton *button in _topBarView.subviews) {
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(inputManager:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    //Create the focus reticule UIView
    _focalReticule = [CameraFocalReticule new];

    if (_focalReticule) {
        _focalReticule.frame = (CGRect){0, 0, 60, 60};
        _focalReticule.backgroundColor = [UIColor clearColor];
        _focalReticule.hidden = YES;
        [self.view addSubview:_focalReticule];
    }

    [self.preViewPhoto removeFromSuperview];
    [self.view addSubview:self.preViewPhoto];
    [self.view bringSubviewToFront:self.preViewPhoto];

    //Create the gesture recognizer for the focus tap
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    if (singleTapGestureRecognizer) [self.view addGestureRecognizer:singleTapGestureRecognizer];
}

#pragma mark - User Interaction

- (void)inputManager:(id)sender
{
    //If animation is in progress, ignore input
    if (_animationInProgress) return;

    //If sender does not inherit from 'UIButton', return
    if (![sender isKindOfClass:[UIButton class]]) return;

    //Input manager switch
    switch ([(UIButton *)sender tag]) {
        case ShutterButtonTag:
            [self onTapShutterButton];
            return;
        case ToggleButtonTag:
            [self onTapToggleButton];
            return;
        case FlashButtonTag:
            [self onTapFlashButton];
            return;
        case DismissButtonTag:
            [self onTapDismissButton];
            return;
    }
}

- (void)onTapShutterButton
{
    //Animate shutter release
    [self animateShutterRelease];

    //Capture image from camera
    [_captureManager captureStillImage];
}

- (void)onTapFlashButton
{
    BOOL enable = !self.captureManager.isTorchEnabled;
    self.captureManager.enableTorch = enable;
}

- (void)onTapToggleButton
{
    if (cameraBeingUsed == RearFacingCamera) {
        [self setupCaptureManager:FrontFacingCamera];
        cameraBeingUsed = FrontFacingCamera;
        [self composeInterface];
        [[_captureManager captureSession] startRunning];
        _cameraFlash.hidden = YES;
    } else {
        [self setupCaptureManager:RearFacingCamera];
        cameraBeingUsed = RearFacingCamera;
        [self composeInterface];
        [[_captureManager captureSession] startRunning];
        _cameraFlash.hidden = NO;
    }
}

- (void)onTapDismissButton
{
    [_captureManager stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)focusGesture:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;
        if (tap.state == UIGestureRecognizerStateRecognized) {
            CGPoint location = [sender locationInView:self.view];

            [self focusAtPoint:location
                completionHandler:^{
                    [self animateFocusReticuleToPoint:location];
                }];
        }
    }
}

#pragma mark - Animation

- (void)animateShutterRelease
{
    _animationInProgress = YES; //Disables input manager

    [UIView animateWithDuration:.1
        animations:^{
            self.cameraShutter.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:.1
                animations:^{
                    self.cameraShutter.transform = CGAffineTransformMakeScale(1, 1);
                }
                completion:^(BOOL finished) {

                    self.animationInProgress = NO; //Enables input manager
                }];
        }];
}

- (void)animateFocusReticuleToPoint:(CGPoint)targetPoint
{
    self.animationInProgress = YES; //Disables input manager

    [self.focalReticule setCenter:targetPoint];
    self.focalReticule.alpha = 0.0;
    self.focalReticule.hidden = NO;

    [UIView animateWithDuration:0.4
        animations:^{
            self.focalReticule.alpha = 1.0;
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4
                animations:^{
                    self.focalReticule.alpha = 0.0;
                }
                completion:^(BOOL finished) {

                    self.animationInProgress = NO; //Enables input manager
                }];
        }];
}

- (void)orientationChanged:(NSNotification *)notification
{
    //Animate top bar buttons on orientation changes
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait: {
            //Standard device orientation (Portrait)
            [UIView animateWithDuration:0.6
                             animations:^{
                                 CGAffineTransform transform = CGAffineTransformMakeRotation(0);

                                 self.cameraFlash.transform = transform;
                                 self.cameraFlash.center = CGPointMake(self.cameraFlash.frame.origin.x + 20, self.topBarView.center.y);

                                 self.cameraToggle.transform = transform;
                                 self.cameraToggle.center = CGPointMake(self.cameraToggle.frame.origin.x + 20, self.topBarView.center.y);

                                 self.cameraDismiss.center = CGPointMake(25, self.topBarView.center.y);
                             }];
        } break;
        case UIDeviceOrientationLandscapeLeft: {
            //Device orientation changed to landscape left
            [UIView animateWithDuration:0.6
                             animations:^{
                                 CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);

                                self.cameraFlash.transform = transform;
                                 self.cameraFlash.center = CGPointMake(self.topBarView.center.x * 1.25, self.topBarView.center.y);

                                 self.cameraToggle.transform = transform;
                                 self.cameraToggle.center = CGPointMake(self.topBarView.center.x * 1.60, self.topBarView.center.y);

                                 self.cameraDismiss.center = CGPointMake(self.topBarView.center.x * 0.25, self.topBarView.center.y);
                             }];
        } break;
        case UIDeviceOrientationLandscapeRight: {
            //Device orientation changed to landscape right
            [UIView animateWithDuration:0.6
                             animations:^{
                                 CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);

                                 self.cameraFlash.transform = transform;
                                 self.cameraFlash.center = CGPointMake(self.topBarView.center.x * 0.40, self.topBarView.center.y);

                                 self.cameraToggle.transform = transform;
                                 self.cameraToggle.center = CGPointMake(self.topBarView.center.x * 0.75, self.topBarView.center.y);

                                 self.cameraDismiss.center = CGPointMake(self.topBarView.center.x * 1.75, self.topBarView.center.y);
                             }];
        } break;
        default:;
    }
}


#pragma mark - Camera Session Manager Delegate Methods

- (void)cameraSessionManagerDidCaptureImage
{
    [self.captureManager.captureSession stopRunning];
    [self.cameraPreView setPhoto:[self fixOrientation:[[self captureManager] stillImage]]];
    self.preViewPhoto.hidden = NO;
}

- (void)cameraSessionManagerFailedToCaptureImage
{
}

- (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType
{
}

- (void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics
{
}

#pragma mark - Helper Methods

- (void)focusAtPoint:(CGPoint)point completionHandler:(void (^)(void))completionHandler
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.view.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));

    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        //Lock camera for configuration if possible
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }

            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }

            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }

            [device unlockForConfiguration];

            completionHandler();
        }
    } else {
        completionHandler();
    }
}

#pragma mark -
#pragma mark :. 转屏handle
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationMaskAllButUpsideDown);
//}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - API Functions

- (void)setTopBarColor:(UIColor *)topBarColor
{
    _topBarView.backgroundColor = topBarColor;
}

- (void)hideFlashButton
{
    _cameraFlash.hidden = YES;
}

- (void)hideCameraToggleButton
{
    _cameraToggle.hidden = YES;
}

- (void)hideDismissButton
{
    _cameraDismiss.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)preViewPhoto
{
    if (!_preViewPhoto) {
        _preViewPhoto = [[UIView alloc] initWithFrame:self.view.bounds];
        _preViewPhoto.backgroundColor = [UIColor blackColor];
        _preViewPhoto.hidden = YES;

        UIView *toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, _preViewPhoto.frame.size.height - 70, _preViewPhoto.frame.size.width, 70)];
        toolbarView.backgroundColor = [UIColor blackColor];
        [_preViewPhoto addSubview:toolbarView];

        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 60, 50)];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(didCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [toolbarView addSubview:cancel];


        UIButton *complete = [[UIButton alloc] initWithFrame:CGRectMake(toolbarView.frame.size.width - 70, 10, 60, 50)];
        [complete setTitle:@"确定" forState:UIControlStateNormal];
        [complete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [complete addTarget:self action:@selector(didCompleteClick) forControlEvents:UIControlEventTouchUpInside];
        [toolbarView addSubview:complete];

        [_preViewPhoto addSubview:self.cameraPreView];
    }
    return _preViewPhoto;
}

- (CCCameraPreview *)cameraPreView
{
    if (!_cameraPreView) {
        CGRect frame = self.preViewPhoto.frame;
        frame.size.height -= 70;
        _cameraPreView = [[CCCameraPreview alloc] initWithFrame:frame];
    }
    return _cameraPreView;
}

- (void)didCompleteClick
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didCaptureImage:)])
            [self.delegate didCaptureImage:[self fixOrientation:[[self captureManager] stillImage]]];

        if ([self.delegate respondsToSelector:@selector(didCaptureImageWithData:)])
            [self.delegate didCaptureImageWithData:[[self captureManager] stillImageData]];
    }
    [self onTapDismissButton];
}

- (void)didCancelClick
{
    self.preViewPhoto.hidden = YES;
    [self.captureManager.captureSession startRunning];
}

/// 修正图片转向
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }

    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

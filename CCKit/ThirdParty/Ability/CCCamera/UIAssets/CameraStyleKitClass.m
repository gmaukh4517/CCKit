//
//  CameraStyleKitClass.m
//  CCKit
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
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

#import "CameraStyleKitClass.h"


@implementation CameraStyleKitClass

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawCameraShutterWithFrame: (CGRect)frame
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 0.812 green: 0.812 blue: 0.812 alpha: 0.62];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.03691 + 0.12) + 0.38, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.03466 + 0.43) + 0.07, floor(CGRectGetWidth(frame) * 0.96691 + 0.12) - floor(CGRectGetWidth(frame) * 0.03691 + 0.12), floor(CGRectGetHeight(frame) * 0.96466 + 0.43) - floor(CGRectGetHeight(frame) * 0.03466 + 0.43));


    //// Page-1
    {
        //// Portrait
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.62);
            CGContextBeginTransparencyLayer(context, NULL);


            //// CameraShutterVector Drawing
            UIBezierPath* cameraShutterVectorPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(page1) + floor(CGRectGetWidth(page1) * 0.00000 + 0.5), CGRectGetMinY(page1) + floor(CGRectGetHeight(page1) * 0.00000 + 0.5), floor(CGRectGetWidth(page1) * 1.00000 + 0.5) - floor(CGRectGetWidth(page1) * 0.00000 + 0.5), floor(CGRectGetHeight(page1) * 1.00000 + 0.5) - floor(CGRectGetHeight(page1) * 0.00000 + 0.5))];
            [color1 setFill];
            [cameraShutterVectorPath fill];
            [color0 setStroke];
            cameraShutterVectorPath.lineWidth = 3;
            [cameraShutterVectorPath stroke];


            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
}

+ (void)drawCameraFlashWithFrame: (CGRect)frame
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.16636 + 0.23) + 0.27, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.03852 + 0.2) + 0.3, floor(CGRectGetWidth(frame) * 0.83136 + 0.23) - floor(CGRectGetWidth(frame) * 0.16636 + 0.23), floor(CGRectGetHeight(frame) * 0.96352 + 0.2) - floor(CGRectGetHeight(frame) * 0.03852 + 0.2));


    //// Page-1
    {
        //// Portrait
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.8);
            CGContextBeginTransparencyLayer(context, NULL);


            //// FlashVector Drawing
            UIBezierPath* flashVectorPath = UIBezierPath.bezierPath;
            [flashVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.17944 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.45268 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.45896 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.55598 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.90397 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.55854 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.64845 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.45124 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1))];
            [flashVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1))];
            [flashVectorPath closePath];
            flashVectorPath.miterLimit = 4;

            flashVectorPath.usesEvenOddFillRule = YES;

            [color setFill];
            [flashVectorPath fill];


            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
}

+ (void)drawCameraToggleWithFrame: (CGRect)frame
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.02908 - 0.32) + 0.82, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01817 + 0.13) + 0.37, floor(CGRectGetWidth(frame) * 0.97408 - 0.32) - floor(CGRectGetWidth(frame) * 0.02908 - 0.32), floor(CGRectGetHeight(frame) * 0.98317 + 0.13) - floor(CGRectGetHeight(frame) * 0.01817 + 0.13));


    //// Page-1
    {
        //// Portrait
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.8);
            CGContextBeginTransparencyLayer(context, NULL);


            //// CameraToggleVector Drawing
            UIBezierPath* cameraToggleVectorPath = UIBezierPath.bezierPath;
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.29844 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.71159 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.23289 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.26224 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.74989 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.23289 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.28882 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.23289 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.21947 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.29844 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.25052 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.23289 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.21947 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.26224 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.21947 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.69811 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.28882 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.76367 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.21947 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.73432 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.25052 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.76367 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.71159 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.76367 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.69811 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.74989 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.76367 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.73432 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.29844 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.78093 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.29844 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.35839 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.64822 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49827 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.58197 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.35839 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.64822 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.42102 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.63816 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.64822 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.57553 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.58197 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.63816 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.35229 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49827 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.41853 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.63816 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.35229 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.57553 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.35839 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.35229 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.42102 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.41853 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.35839 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.35839 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.39265 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.61199 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49828 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.56196 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.39265 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.61199 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.43994 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.60391 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.61199 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.55662 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.56196 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.60391 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.38852 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49828 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.43854 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.60391 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.38852 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.55662 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.50025 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.39265 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.38852 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.43994 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.43854 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.39265 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.55331 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93945 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.46313 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.55331 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.95963 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87890 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.55331 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.91927 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.46313 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87890 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93945 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.43560 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87890 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.91927 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.95963 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.43560 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44509 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54376 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96935 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.56951 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.94150 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.55898 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.95916 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.56951 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.94915 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.53831 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.91011 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.56951 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93296 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.55641 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.92149 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.93710 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49845 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.76177 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.89176 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.93710 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.71446 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.80324 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.20083 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.93710 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.38156 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.88576 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.27600 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.56357 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.08956 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.73905 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.14237 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.65600 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.10229 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.56113 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06055 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.56233 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.07897 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.56113 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06849 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.56380 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.02956 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.56113 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.05211 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.56248 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.04081 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49845 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.80982 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.05919 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.25782 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54376 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96936 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.74557 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.79941 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.94839 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54376 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96935 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.43424 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96708 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49844 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.18917 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93664 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.73843 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.46250 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.02706 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.24931 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.20387 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.04519 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.42790 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06054 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.44266 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.03911 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.42790 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.05148 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.45250 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.08762 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.42790 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06800 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.43790 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.07770 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.06290 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49844 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.23344 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.11001 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.06290 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.28540 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.43318 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.90687 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.06290 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.70518 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.22349 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87646 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.43628 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.94150 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.43462 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.91929 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.43628 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93215 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.43424 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96708 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.43628 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.94858 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.43533 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.95769 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.43424 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96708 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            [cameraToggleVectorPath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12110 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44090 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06055 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.53107 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12110 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.44090 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.08073 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.44090 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.04037 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.53107 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06055 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.55860 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.04037 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12110 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.08073 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.55860 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12110 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54911 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12110 * CGRectGetHeight(page1))];
            [cameraToggleVectorPath closePath];
            cameraToggleVectorPath.miterLimit = 4;

            cameraToggleVectorPath.usesEvenOddFillRule = YES;

            [color2 setFill];
            [cameraToggleVectorPath fill];


            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
}

+ (void)drawCameraDismissWithFrame: (CGRect)frame
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.07703 + 0.09) + 0.41, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.07659 + 0.5) + 0, floor(CGRectGetWidth(frame) * 0.92543 + 0.41) - floor(CGRectGetWidth(frame) * 0.07703 + 0.09) - 0.32, floor(CGRectGetHeight(frame) * 0.92499 - 0.18) - floor(CGRectGetHeight(frame) * 0.07659 + 0.5) + 0.68);


    //// Page-1
    {
        //// Portrait
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.8);
            CGContextBeginTransparencyLayer(context, NULL);


            //// Shape Drawing
            UIBezierPath* shapePath = UIBezierPath.bezierPath;
            [shapePath moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.00789 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.13838 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.32328 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.45377 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.32225 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.55004 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.37044 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.50178 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.36996 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.50197 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87228 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.12772 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 1.00000 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.03587 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.92109 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.07891 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.96413 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.44996 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.67775 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.54623 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.67672 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.49833 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.62970 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.49837 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.62962 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.86162 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.99211 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.99211 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.86162 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.91121 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.95519 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.95519 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.91121 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.67672 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.54623 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.67775 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.44996 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.62944 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49883 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.62919 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.49872 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 1.00000 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12772 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.87228 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00000 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.96413 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.07891 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.92109 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.03587 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.55004 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.32225 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.45377 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.32328 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.50206 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.37032 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.50186 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.37051 * CGRectGetHeight(page1))];
            [shapePath addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.13838 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.00789 * CGRectGetHeight(page1))];
            [shapePath addCurveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.00789 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.13838 * CGRectGetHeight(page1)) controlPoint1: CGPointMake(CGRectGetMinX(page1) + 0.08879 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.04481 * CGRectGetHeight(page1)) controlPoint2: CGPointMake(CGRectGetMinX(page1) + 0.04481 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.08879 * CGRectGetHeight(page1))];
            [shapePath closePath];
            shapePath.miterLimit = 4;

            shapePath.usesEvenOddFillRule = YES;

            [color3 setFill];
            [shapePath fill];


            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
}

+ (void)drawCameraTopBarWithFrame: (CGRect)frame
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color4 = [UIColor colorWithRed: 0.176 green: 0.478 blue: 0.529 alpha: 0.64];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.00000 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * -0.00176 + 0.15) + 0.35, floor(CGRectGetWidth(frame) * 1.00000 + 0.5) - floor(CGRectGetWidth(frame) * 0.00000 + 0.5), floor(CGRectGetHeight(frame) * 0.99824 + 0.15) - floor(CGRectGetHeight(frame) * -0.00176 + 0.15));


    //// Page-1
    {
        //// Portrait
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.64);
            CGContextBeginTransparencyLayer(context, NULL);


            //// TopBar Drawing
            UIBezierPath* topBarPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(page1) + floor(CGRectGetWidth(page1) * 0.00000 + 0.5), CGRectGetMinY(page1) + floor(CGRectGetHeight(page1) * 0.00000 + 0.5), floor(CGRectGetWidth(page1) * 1.00000 + 0.5) - floor(CGRectGetWidth(page1) * 0.00000 + 0.5), floor(CGRectGetHeight(page1) * 1.00000 + 0.5) - floor(CGRectGetHeight(page1) * 0.00000 + 0.5))];
            [color4 setFill];
            [topBarPath fill];


            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
    }
}

+ (void)drawCameraFocusWithFrame: (CGRect)frame
{
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color6 = [UIColor colorWithRed: 0.521 green: 0.521 blue: 0.521 alpha: 1];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.03763 - 0.03) + 0.53, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.03815 + 0.13) + 0.37, floor(CGRectGetWidth(frame) * 0.96263 - 0.03) - floor(CGRectGetWidth(frame) * 0.03763 - 0.03), floor(CGRectGetHeight(frame) * 0.96315 + 0.13) - floor(CGRectGetHeight(frame) * 0.03815 + 0.13));


    //// Page-1
    {
        //// Portrait
        {
            //// Group 4
            {
                //// Rectangle-6 Drawing
                UIBezierPath* rectangle6Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(page1) + floor(CGRectGetWidth(page1) * 0.00000 + 0.5), CGRectGetMinY(page1) + floor(CGRectGetHeight(page1) * 0.00000 + 0.5), floor(CGRectGetWidth(page1) * 1.00000 + 0.5) - floor(CGRectGetWidth(page1) * 0.00000 + 0.5), floor(CGRectGetHeight(page1) * 1.00000 + 0.5) - floor(CGRectGetHeight(page1) * 0.00000 + 0.5))];
                [color6 setStroke];
                rectangle6Path.lineWidth = 3;
                [rectangle6Path stroke];


                //// Rectangle-2 Drawing
                UIBezierPath* rectangle2Path = UIBezierPath.bezierPath;
                [rectangle2Path moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.10711 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06860 * CGRectGetHeight(page1))];
                [rectangle2Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.89268 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06860 * CGRectGetHeight(page1))];
                [rectangle2Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.83737 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12403 * CGRectGetHeight(page1))];
                [rectangle2Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.16245 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.12403 * CGRectGetHeight(page1))];
                [rectangle2Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.10711 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.06860 * CGRectGetHeight(page1))];
                [rectangle2Path closePath];
                rectangle2Path.miterLimit = 4;

                rectangle2Path.usesEvenOddFillRule = YES;

                [color0 setFill];
                [rectangle2Path fill];


                //// Rectangle-4 Drawing
                UIBezierPath* rectangle4Path = UIBezierPath.bezierPath;
                [rectangle4Path moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.93140 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.10715 * CGRectGetHeight(page1))];
                [rectangle4Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.93140 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.89279 * CGRectGetHeight(page1))];
                [rectangle4Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.87597 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.83746 * CGRectGetHeight(page1))];
                [rectangle4Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.87597 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.16255 * CGRectGetHeight(page1))];
                [rectangle4Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.93140 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.10715 * CGRectGetHeight(page1))];
                [rectangle4Path closePath];
                rectangle4Path.miterLimit = 4;

                rectangle4Path.usesEvenOddFillRule = YES;

                [color0 setFill];
                [rectangle4Path fill];


                //// Rectangle-8 Drawing
                UIBezierPath* rectangle8Path = UIBezierPath.bezierPath;
                [rectangle8Path moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.06860 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.89279 * CGRectGetHeight(page1))];
                [rectangle8Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.06860 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.10717 * CGRectGetHeight(page1))];
                [rectangle8Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.12403 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.16274 * CGRectGetHeight(page1))];
                [rectangle8Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.12403 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.83738 * CGRectGetHeight(page1))];
                [rectangle8Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.06860 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.89279 * CGRectGetHeight(page1))];
                [rectangle8Path closePath];
                rectangle8Path.miterLimit = 4;

                rectangle8Path.usesEvenOddFillRule = YES;

                [color0 setFill];
                [rectangle8Path fill];


                //// Rectangle-5 Drawing
                UIBezierPath* rectangle5Path = UIBezierPath.bezierPath;
                [rectangle5Path moveToPoint: CGPointMake(CGRectGetMinX(page1) + 0.89293 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93140 * CGRectGetHeight(page1))];
                [rectangle5Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.10727 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93140 * CGRectGetHeight(page1))];
                [rectangle5Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.16282 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87597 * CGRectGetHeight(page1))];
                [rectangle5Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.83743 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.87597 * CGRectGetHeight(page1))];
                [rectangle5Path addLineToPoint: CGPointMake(CGRectGetMinX(page1) + 0.89293 * CGRectGetWidth(page1), CGRectGetMinY(page1) + 0.93140 * CGRectGetHeight(page1))];
                [rectangle5Path closePath];
                rectangle5Path.miterLimit = 4;

                rectangle5Path.usesEvenOddFillRule = YES;

                [color0 setFill];
                [rectangle5Path fill];
            }
        }
    }
}

+ (void)drawLaunchCameraWithFrame: (CGRect)frame pressed: (BOOL)pressed
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* color6 = [UIColor colorWithRed: 0.521 green: 0.521 blue: 0.521 alpha: 1];
    UIColor* color7 = [UIColor colorWithRed: 0.69 green: 0.769 blue: 0.871 alpha: 0.78];
    UIColor* color8 = [UIColor colorWithRed: 0.225 green: 0.225 blue: 0.225 alpha: 1];


    //// Subframes
    CGRect page1 = CGRectMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 9.97, floor((CGRectGetWidth(frame) - 9) * 1.28692 + 0.5), floor((CGRectGetHeight(frame) - 9.97) * 0.88715 + 10.44) - 9.94);
    CGRect page2 = CGRectMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 9.97, floor((CGRectGetWidth(frame) - 9) * 1.28692 + 0.5), floor((CGRectGetHeight(frame) - 9.97) * 0.88715 + 10.44) - 9.94);


    //// Page-1
    {
        //// Artboard-1
        {
            //// Rectangle-1-+-Launch-Camera 2
            {
                //// Rectangle-1 Drawing
                UIBezierPath* rectangle1Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(page1) + floor(CGRectGetWidth(page1) * 0.00000 + 0.5), CGRectGetMinY(page1) + floor(CGRectGetHeight(page1) * 0.00000 + 0.5), floor(CGRectGetWidth(page1) * 0.74754 + 0.5) - floor(CGRectGetWidth(page1) * 0.00000 + 0.5), floor(CGRectGetHeight(page1) * 1.00000 + 0.5) - floor(CGRectGetHeight(page1) * 0.00000 + 0.5)) cornerRadius: 8];
                [color0 setFill];
                [rectangle1Path fill];
                [color6 setStroke];
                rectangle1Path.lineWidth = 3;
                [rectangle1Path stroke];


                //// Rectangle 2 Drawing
                CGRect rectangle2Rect = CGRectMake(CGRectGetMinX(page1) + floor(CGRectGetWidth(page1) * 0.14754 + 0.5), CGRectGetMinY(page1) + floor(CGRectGetHeight(page1) * 0.30592 + 0.22) + 0.28, floor(CGRectGetWidth(page1) * 1.00000 + 0.5) - floor(CGRectGetWidth(page1) * 0.14754 + 0.5), floor(CGRectGetHeight(page1) * 0.86930 + 0.22) - floor(CGRectGetHeight(page1) * 0.30592 + 0.22));
                NSMutableParagraphStyle* rectangle2Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
                rectangle2Style.alignment = NSTextAlignmentLeft;

                NSDictionary* rectangle2FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 20], NSForegroundColorAttributeName: color8, NSParagraphStyleAttributeName: rectangle2Style};

                [@"Launch Camera" drawInRect: rectangle2Rect withAttributes: rectangle2FontAttributes];
            }
        }
    }


    //// Page-
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(frame) + 9.5, CGRectGetMinY(frame) + 9.5);



        //// Artboard-
        {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 2, 2);



            //// Rectangle-1-+-Launch-Camera 3
            {
            }



            CGContextRestoreGState(context);
        }



        CGContextRestoreGState(context);
    }


    if (pressed)
    {
        //// Page- 2
        {
            //// Artboard- 2
            {
                //// Rectangle-1-+-Launch-Camera 4
                {
                    //// Rectangle- Drawing
                    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(page2) + floor(CGRectGetWidth(page2) * 0.00000 + 0.5), CGRectGetMinY(page2) + floor(CGRectGetHeight(page2) * 0.00000 + 0.5), floor(CGRectGetWidth(page2) * 0.74754 + 0.5) - floor(CGRectGetWidth(page2) * 0.00000 + 0.5), floor(CGRectGetHeight(page2) * 1.00000 + 0.5) - floor(CGRectGetHeight(page2) * 0.00000 + 0.5)) cornerRadius: 8];
                    [color7 setFill];
                    [rectanglePath fill];
                    [color7 setStroke];
                    rectanglePath.lineWidth = 3;
                    [rectanglePath stroke];


                    //// Rectangle 3 Drawing
                    CGRect rectangle3Rect = CGRectMake(CGRectGetMinX(page2) + floor(CGRectGetWidth(page2) * 0.14754 + 0.5), CGRectGetMinY(page2) + floor(CGRectGetHeight(page2) * 0.30592 + 0.22) + 0.28, floor(CGRectGetWidth(page2) * 1.00000 + 0.5) - floor(CGRectGetWidth(page2) * 0.14754 + 0.5), floor(CGRectGetHeight(page2) * 0.86930 + 0.22) - floor(CGRectGetHeight(page2) * 0.30592 + 0.22));
                    NSMutableParagraphStyle* rectangle3Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
                    rectangle3Style.alignment = NSTextAlignmentLeft;

                    NSDictionary* rectangle3FontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 20], NSForegroundColorAttributeName: color0, NSParagraphStyleAttributeName: rectangle3Style};

                    [@"Launch Camera" drawInRect: rectangle3Rect withAttributes: rectangle3FontAttributes];
                }
            }
        }
    }
}

@end

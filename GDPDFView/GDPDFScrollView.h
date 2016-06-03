//
// Copyright © 2016 Gavrilov Daniil
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

#import <UIKit/UIKit.h>

#import "GDPDFViewDelegate.h"

@interface GDPDFScrollView : UIScrollView <GDPDFViewProperties, GDPDFContainerViewProperties>

/**
 Instantiates and return GDPDFScrollView class instance
 @param filePathURL NSURL to the PDF file saved on device, may be nil
 @return GDPDFScrollView class instance
 */
- (instancetype)initWithFilePathURL:(NSURL *)filePathURL;

/**
 Instantiates and return GDPDFScrollView class instance
 @param filePathURL NSURL to the PDF file saved on device, may be nil
 @param PDFViewDelegate GDPDFViewDelegate protocol delegate, may be nil
 @return GDPDFScrollView class instance
 */
- (instancetype)initWithFilePathURL:(NSURL *)filePathURL PDFViewDelegate:(id<GDPDFViewDelegate>)PDFViewDelegate;

/**
 Should be called to center content view. By default called
 in scrollViewDidZoom methods of UIScrollView delegate
 */
- (void)centerContent;

/**
 Should be called to render PDF pages. By default called
 in scrollViewDidScroll and scrollViewDidZoom methods of
 UIScrollView delegate
 */
- (void)renderContent;

/**
 Clean current content
 */
- (void)clean;


/**
 GDPDFViewDelegate protocol delegate
 */
@property (nonatomic, weak) id<GDPDFViewDelegate> PDFViewDelegate;

/**
 Returns scroll view's content view
 */
@property (nonatomic, strong, readonly) UIView *contentView;

@end

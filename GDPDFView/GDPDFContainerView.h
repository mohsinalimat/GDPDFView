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

#import "GDPDFContainerViewProperties.h"
@class GDPDFImageView;

@interface GDPDFContainerView : UIView <GDPDFContainerViewProperties>

/**
 Instantiates and return GDPDFContainerView class instance
 @param imageViews Array of GDPDFImageView objects, may be nil
 @return GDPDFContainerView class instance
 */
- (instancetype)initWithImageViews:(NSArray<GDPDFImageView *> *)imageViews;

/**
 Clean or render content of pages based on their visibility, 
 also determine and return new current page number
 @param rect Visible frame rectangle
 @param currentPage Current page number
 @return New current page number
 */
- (NSInteger)renderPagesInRect:(CGRect)rect withCurrentPage:(NSInteger)currentPage;

/**
 Layouts image views and set own frame based on maximum 
 width of content and newly calculated height
 */
- (void)layoutImageViews;


/**
 Width of container view based on maximum width of content
 */
@property (nonatomic, readonly) CGFloat width;

/**
 Height of container view based on calculated height of content
 */
@property (nonatomic, readonly) CGFloat height;

/**
 Array of GDPDFImageView objects
 */
@property (nonatomic, strong) NSArray<GDPDFImageView *> *imageViews;

@end

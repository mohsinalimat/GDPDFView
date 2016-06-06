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

@class OHVectorImage;

@interface GDPDFImageView : UIImageView

/**
 Instantiates and return GDPDFImageView class instance
 @param vectorImage OHVectorImage object instantiated with PDF page
 @return GDPDFImageView class instance
 */
- (instancetype)initWithVectorImage:(OHVectorImage *)vectorImage;

/**
 Draw page image in specified operation queue
 @param operationQueue Operation queue to render page image
 */
- (void)drawInOperationQueue:(NSOperationQueue *)operationQueue;

/**
 Clean current page image, place page thumbnail instead if enabled
 */
- (void)clean;

/**
 Add or remove activity indicator, which is visible only when page image is not rendered
 @param showActivityIndicator If YES instantiate activity indicator and place it if needed, 
 if NO remove activity indicator and clean ivar
 */
- (void)showActivityIndicator:(BOOL)showActivityIndicator;

/**
 Draw or clean page thumbnail in specified operation queue
 @param showThumbnail If YES draw thumbnail and place it if needed, 
 if NO remove thumbnail
 */
- (void)showThumbnail:(BOOL)showThumbnail;

/**
 Set maximum image size, will be applyed in next drawing of page image
 @param imageSize Maximum size of rendered page image, image will
 be rendered at size that fits imageSize if page image size is bigger
 */
- (void)changeImageSize:(CGSize)imageSize;

/**
 Set thumbnail size, will be applyed in next drawing of page image
 @param thumbnailSize Size of rendered page thumbnail, thumbnail
 will be rendered at size that fits thumbnailSize
 */
- (void)changeThumbnailSize:(CGSize)thumbnailSize;


/**
 Width of image view based on rendered image size
 */
@property (nonatomic, readonly) CGFloat width;

/**
 Height of image view based on rendered image size
 */
@property (nonatomic, readonly) CGFloat height;

@end

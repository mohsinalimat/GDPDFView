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
#import "GDPDFImageView.h"

#import <OHPDFImage/OHVectorImage.h>

@interface GDPDFImageView ()

@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat height;

@property (nonatomic, strong) OHVectorImage *vectorImage;
@property (nonatomic, strong) NSOperation *imageOperation;
@property (nonatomic, strong) NSOperation *thumbnailOperation;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImage *thumbnail;

@property (nonatomic) BOOL showActivityIndicator;
@property (nonatomic) BOOL showThumbnail;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize thumbnailSize;

@end

@implementation GDPDFImageView

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (instancetype)initWithVectorImage:(OHVectorImage *)vectorImage {
    self = [super init];
    if (self) {
        self.vectorImage = vectorImage;
        self.showActivityIndicator = YES;
        self.showThumbnail = YES;
        self.imageSize = CGSizeZero;
        self.thumbnailSize = CGSizeZero;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [self stopOperations];
}

#pragma mark -
#pragma mark - Public Methods

- (void)drawInOperationQueue:(NSOperationQueue *)operationQueue {
    if (self.image && ![self.image isEqual:self.thumbnail]) {
        return;
    }
    
    [self stopImageOperation];
    __weak GDPDFImageView *wSelf = self;
    self.imageOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong GDPDFImageView *sSelf = wSelf;
        [sSelf drawImage];
    }];
    [operationQueue addOperation:self.imageOperation];
}

- (void)clean {
    [self stopImageOperation];
    [self.activityIndicator startAnimating];
    [self setImage:self.thumbnail];
}

- (void)showActivityIndicator:(BOOL)showActivityIndicator {
    self.showActivityIndicator = showActivityIndicator;
    
    if (showActivityIndicator) {
        [self addActivityIndicator];
    } else {
        [self removeActivityIndicator];
    }
}

- (void)showThumbnail:(BOOL)showThumbnail inOperationQueue:(NSOperationQueue *)operationQueue {
    self.showThumbnail = showThumbnail;
    
    if (showThumbnail) {
        [self addThumbnailImageInOperationQueue:operationQueue];
    } else {
        [self removeThumbnailImage];
    }
}

- (void)changeImageSize:(CGSize)imageSize {
    if (CGSizeEqualToSize(imageSize, CGSizeZero) || CGSizeEqualToSize(imageSize, self.imageSize)) {
        return;
    }
    
    self.imageSize = imageSize;
    
    [self setupImageViewSize];
}

- (void)changeThumbnailSize:(CGSize)thumbnailSize inOperationQueue:(NSOperationQueue *)operationQueue {
    if (CGSizeEqualToSize(thumbnailSize, CGSizeZero) || CGSizeEqualToSize(thumbnailSize, self.thumbnailSize)) {
        return;
    }
    
    self.thumbnailSize = thumbnailSize;
    
    if (self.showThumbnail) {
        [self addThumbnailImageInOperationQueue:operationQueue];
    }
}

#pragma mark -
#pragma mark - Private Methods

#pragma mark - Default Setups

- (void)setupImageViewSize {
    CGSize scaledSize = self.vectorImage.nativeSize;
    if (!CGSizeEqualToSize(self.imageSize, CGSizeZero) && (self.vectorImage.nativeSize.width > self.imageSize.width || self.vectorImage.nativeSize.height > self.imageSize.height)) {
        scaledSize = [self.vectorImage sizeThatFits:self.imageSize];
    }
    
    self.width = scaledSize.width;
    self.height = scaledSize.height;
}

#pragma mark - Activity Indicator

- (void)addActivityIndicator {
    if (self.activityIndicator) {
        return;
    }
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidesWhenStopped:YES];
    [self addSubview:self.activityIndicator];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_activityIndicator]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_activityIndicator)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_activityIndicator]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_activityIndicator)]];
}

- (void)removeActivityIndicator {
    if (!self.activityIndicator) {
        return;
    }
    
    [NSLayoutConstraint deactivateConstraints:self.activityIndicator.constraints];
    
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}

#pragma mark - Thumbnail Image

- (void)addThumbnailImageInOperationQueue:(NSOperationQueue *)operationQueue {
    [self stopThumbnailOperation];
    
    __weak GDPDFImageView *wSelf = self;
    self.thumbnailOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong GDPDFImageView *sSelf = wSelf;
        
        UIImage *thumbnailImage = [sSelf.vectorImage renderAtSizeThatFits:sSelf.thumbnailSize];
        [sSelf applyNewThumbnailImage:thumbnailImage];
    }];
    
    [operationQueue addOperation:self.thumbnailOperation];
}

- (void)applyNewThumbnailImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.image || (self.image && [self.image isEqual:self.thumbnail])) {
            [self setImage:image];
        }
        [self setThumbnail:image];
    });
}

- (void)removeThumbnailImage {
    [self stopThumbnailOperation];
    
    self.thumbnail = nil;
}

#pragma mark - Support Methods

- (void)drawImage {
    CGSize scaledSize = self.vectorImage.nativeSize;
    if (!CGSizeEqualToSize(self.imageSize, CGSizeZero) && (self.vectorImage.nativeSize.width > self.imageSize.width || self.vectorImage.nativeSize.height > self.imageSize.height)) {
        scaledSize = self.imageSize;
    }
    
    UIImage *image = [self.vectorImage renderAtSizeThatFits:scaledSize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self setImage:image];
    });
}

- (void)stopImageOperation {
    [self.imageOperation cancel];
    self.imageOperation = nil;
}

- (void)stopThumbnailOperation {
    [self.thumbnailOperation cancel];
    self.thumbnailOperation = nil;
}

- (void)stopOperations {
    [self stopImageOperation];
    [self stopThumbnailOperation];
}

@end

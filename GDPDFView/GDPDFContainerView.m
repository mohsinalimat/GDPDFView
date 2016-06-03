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

#import "GDPDFContainerView.h"

#import "GDPDFImageView.h"

@interface GDPDFContainerView ()

@property (nonatomic, strong) NSOperationQueue *imagesOperationQueue;
@property (nonatomic, strong) NSOperationQueue *thumbnailsOperationQueue;

@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat height;

@end

@implementation GDPDFContainerView

@synthesize visibilityFactor = _visibilityFactor;
@synthesize shouldShowThumbnails = _shouldShowThumbnails;
@synthesize shouldShowActivityIndicator = _shouldShowActivityIndicator;
@synthesize maximumPageImageSize = _maximumPageImageSize;
@synthesize pageThumbnailSize = _pageThumbnailSize;

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (instancetype)initWithImageViews:(NSArray *)imageViews imagesOperationQueue:(NSOperationQueue *)imagesOperationQueue thumbnailsOperationQueue:(NSOperationQueue *)thumbnailsOperationQueue {
    self = [super init];
    if (self) {
        self.imageViews = imageViews;
        self.imagesOperationQueue = imagesOperationQueue;
        self.thumbnailsOperationQueue = thumbnailsOperationQueue;
        self.visibilityFactor = 0.90f;
        self.backgroundColor = [UIColor clearColor];
        
        [self setupContainerView];
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    if (![self.imageViews containsObject:(id)view]) {
        return;
    }
    [super addSubview:view];
}

- (void)dealloc {
    [self stopOperations];
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    self.imageViews = nil;
}

#pragma mark -
#pragma mark - Public Methods

- (void)layoutImageViews {
    [self layoutContainerViewWithImageViews:self.imageViews maxWidth:self.width];
}

- (NSInteger)renderPagesInRect:(CGRect)rect withCurrentPage:(NSInteger)currentPage {
    if ([self.imageViews count] == 0) {
        return 0;
    }
    
    if (currentPage < 0) {
        currentPage = 0;
    } else if (currentPage >= [self.imageViews count]) {
        currentPage = ([self.imageViews count] - 1);
    }
    
    CGRect roundedRect = [self roundedRectFromRect:rect];
    
    NSInteger newCurrentPage = currentPage;
    NSMutableArray *fullyVisiblePages = [NSMutableArray new];
    BOOL currentPageIsFullyVisible = NO;
    for (NSInteger i = 0; i < [self.imageViews count]; i++) {
        if (i == 0) {
            GDPDFImageView *currentImageView = [self.imageViews objectAtIndex:currentPage];
            if ([self pageIsVisible:currentImageView inRect:roundedRect]) {
                [currentImageView drawInOperationQueue:self.imagesOperationQueue];
                
                if ([self pageIsFullyVisible:currentImageView inRect:roundedRect]) {
                    [fullyVisiblePages addObject:@(currentPage)];
                    currentPageIsFullyVisible = YES;
                }
            }
        } else {
            NSInteger nextPage = currentPage + i;
            NSInteger prevPage = currentPage - i;
            
            BOOL shouldSkipNextPage = ![self renderNextPageAtIndex:nextPage inRect:roundedRect andMarkInFullyVisiblePagesIfNeeded:fullyVisiblePages];
            BOOL shouldSkipPrevPage = ![self renderPreviousPageAtIndex:prevPage inRect:roundedRect andMarkInFullyVisiblePagesIfNeeded:fullyVisiblePages];
            
            if (currentPageIsFullyVisible && shouldSkipNextPage && shouldSkipPrevPage) {
                break;
            }
        }
    }
    
    if ([fullyVisiblePages count] > 0) {
        newCurrentPage = [[fullyVisiblePages valueForKeyPath:@"@max.integerValue"] integerValue];
    }
    
    return newCurrentPage;
}

#pragma mark -
#pragma mark - Private Methods

#pragma mark - Default Setups

- (void)setupContainerView {
    CGFloat maxWidth = [self countMaxWidthAndShouldAddImagesToContainer:YES];
    [self layoutContainerViewWithImageViews:self.imageViews maxWidth:maxWidth];
}

#pragma mark - Drawing Logic

- (BOOL)renderNextPageAtIndex:(NSInteger)nextPage inRect:(CGRect)rect andMarkInFullyVisiblePagesIfNeeded:(NSMutableArray *)fullyVisiblePages {
    BOOL pageIsRendered = NO;
    
    if (nextPage < [self.imageViews count]) {
        GDPDFImageView *nextImageView = [self.imageViews objectAtIndex:nextPage];
        if ([self pageIsVisible:nextImageView inRect:rect]) {
            pageIsRendered = YES;
            [nextImageView drawInOperationQueue:self.imagesOperationQueue];
            
            if ([self pageIsFullyVisible:nextImageView inRect:rect]) {
                [fullyVisiblePages addObject:@(nextPage)];
            }
        } else if (nextPage > 0) {
            GDPDFImageView *imageViewBeforeThat = [self.imageViews objectAtIndex:(nextPage - 1)];
            if ([self pageIsVisible:imageViewBeforeThat inRect:rect]) {
                [nextImageView drawInOperationQueue:self.imagesOperationQueue];
            } else {
                [nextImageView clean];
            }
        } else {
            [nextImageView clean];
        }
    }
    
    return pageIsRendered;
}

- (BOOL)renderPreviousPageAtIndex:(NSInteger)prevPage inRect:(CGRect)rect andMarkInFullyVisiblePagesIfNeeded:(NSMutableArray *)fullyVisiblePages {
    BOOL pageIsRendered = NO;
    
    if (prevPage >= 0) {
        GDPDFImageView *prevImageView = [self.imageViews objectAtIndex:prevPage];
        if ([self pageIsVisible:prevImageView inRect:rect]) {
            pageIsRendered = YES;
            [prevImageView drawInOperationQueue:self.imagesOperationQueue];
            
            if ([self pageIsFullyVisible:prevImageView inRect:rect]) {
                [fullyVisiblePages addObject:@(prevPage)];
            }
        } else if (prevPage < ([self.imageViews count] - 1)) {
            GDPDFImageView *imageViewAfterThat = [self.imageViews objectAtIndex:(prevPage + 1)];
            if ([self pageIsVisible:imageViewAfterThat inRect:rect]) {
                [prevImageView drawInOperationQueue:self.imagesOperationQueue];
            } else {
                [prevImageView clean];
            }
        } else {
            [prevImageView clean];
        }
    }
    
    return pageIsRendered;
}

- (BOOL)pageIsVisible:(GDPDFImageView *)page inRect:(CGRect)rect {
    CGPoint topPoint = [self topPointOfRect:page.frame];
    CGPoint centerPoint = [self centerPointOfRect:page.frame];
    CGPoint bottomPoint = [self bottomPointOfRect:page.frame];
    
    if (CGRectContainsPoint(rect, topPoint) || CGRectContainsPoint(rect, centerPoint) || CGRectContainsPoint(rect, bottomPoint)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)pageIsFullyVisible:(GDPDFImageView *)page inRect:(CGRect)rect {
    CGRect pageRoundedRect = [self roundedRectFromRect:page.frame];
    CGFloat visiblePercent = [self visiblePersentOfRect:pageRoundedRect inRect:rect];
    
    return (visiblePercent >= self.visibilityFactor);
}

#pragma mark - Layout Methods

- (void)layoutContainerViewWithImageViews:(NSArray *)imageViews maxWidth:(CGFloat)maxWidth {
    CGFloat maxHeight = 0.0f;
    for (GDPDFImageView *imageView in imageViews) {
        [imageView setFrame:CGRectMake((maxWidth - imageView.width) / 2.0f, maxHeight, imageView.width, imageView.height)];
        maxHeight += imageView.height;
    }
    
    self.width = maxWidth;
    self.height = maxHeight;
    
    [self setFrame:CGRectMake(0.0f, 0.0f, maxWidth, maxHeight)];
}

- (void)cleanContainerView {
    for (GDPDFImageView *imageView in self.imageViews) {
        [imageView removeFromSuperview];
    }
}

#pragma mark - Support Methods

- (CGPoint)topPointOfRect:(CGRect)rect {
    return CGPointMake(0.0f, CGRectGetMinY(rect));
}

- (CGPoint)bottomPointOfRect:(CGRect)rect {
    return CGPointMake(0.0f, CGRectGetMaxY(rect));
}

- (CGPoint)centerPointOfRect:(CGRect)rect {
    return CGPointMake(0.0f, CGRectGetMidY(rect));
}

- (CGFloat)visiblePersentOfRect:(CGRect)measuringtRect inRect:(CGRect)rect {
    CGFloat visibleMeasuringRectHeight = CGRectGetHeight(measuringtRect);
    if (CGRectGetMinY(rect) > CGRectGetMinY(measuringtRect)) {
        visibleMeasuringRectHeight -= (CGRectGetMinY(rect) - CGRectGetMinY(measuringtRect));
    }
    if (CGRectGetMaxY(rect) < CGRectGetMaxY(measuringtRect)) {
        visibleMeasuringRectHeight -= (CGRectGetMaxY(measuringtRect) - CGRectGetMaxY(rect));
    }
    
    CGFloat rectArea = CGRectGetWidth(rect) * CGRectGetHeight(rect);
    CGFloat fullMeasuringRectArea = CGRectGetWidth(measuringtRect) * CGRectGetHeight(measuringtRect);
    CGFloat visibleMeasuringRectArea = CGRectGetWidth(measuringtRect) * visibleMeasuringRectHeight;
    
    return MAX((visibleMeasuringRectArea / fullMeasuringRectArea), (visibleMeasuringRectArea / rectArea));
}

- (CGRect)roundedRectFromRect:(CGRect)rect {
    return CGRectMake((rect.origin.x), (rect.origin.y), self.width, (rect.size.height));
}

- (CGFloat)countMaxWidthAndShouldAddImagesToContainer:(BOOL)shouldAddImages {
    CGFloat maxWidth = 0.0f;
    for (GDPDFImageView *imageView in self.imageViews) {
        if (shouldAddImages) {
            [self addSubview:imageView];
        }
        if (maxWidth < imageView.width) {
            maxWidth = imageView.width;
        }
    }
    return maxWidth;
}

- (void)stopOperations {
    [self.imagesOperationQueue cancelAllOperations];
    
    [self.thumbnailsOperationQueue cancelAllOperations];
}

#pragma mark -
#pragma mark - Setters

- (void)setImageViews:(NSArray *)imageViews {
    [self stopOperations];
    [self cleanContainerView];
    
    _imageViews = imageViews;
    
    CGFloat maxWidth = [self countMaxWidthAndShouldAddImagesToContainer:YES];
    [self layoutContainerViewWithImageViews:self.imageViews maxWidth:maxWidth];
}

- (void)setVisibilityFactor:(CGFloat)visibilityFactor {
    if (visibilityFactor < 0.1f && visibilityFactor > 1.0f) {
        return;
    }
    
    _visibilityFactor = visibilityFactor;
}

- (void)setShouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator {
    _shouldShowActivityIndicator = shouldShowActivityIndicator;
    
    for (GDPDFImageView *imageView in self.imageViews) {
        [imageView showActivityIndicator:shouldShowActivityIndicator];
    }
}

- (void)setShouldShowThumbnails:(BOOL)shouldShowThumbnails {
    _shouldShowThumbnails = shouldShowThumbnails;
    
    for (GDPDFImageView *imageView in self.imageViews) {
        [imageView showThumbnail:shouldShowThumbnails inOperationQueue:self.thumbnailsOperationQueue];
    }
}

- (void)setMaximumPageImageSize:(CGSize)maximumPageImageSize {
    _maximumPageImageSize = maximumPageImageSize;
    
    CGFloat factor = [[UIScreen mainScreen] scale];
    CGSize maximumPageImageSizeForCurrentScreen = CGSizeMake(maximumPageImageSize.width * factor, maximumPageImageSize.height * factor);
    
    for (GDPDFImageView *imageView in self.imageViews) {
        [imageView changeImageSize:maximumPageImageSizeForCurrentScreen];
    }
    
    CGFloat maxWidth = [self countMaxWidthAndShouldAddImagesToContainer:NO];
    [self layoutContainerViewWithImageViews:self.imageViews maxWidth:maxWidth];
}

- (void)setPageThumbnailSize:(CGSize)pageThumbnailSize {
    _pageThumbnailSize = pageThumbnailSize;
    
    CGFloat factor = [[UIScreen mainScreen] scale];
    CGSize pageThumbnailSizeForCurrentScreen = CGSizeMake(pageThumbnailSize.width * factor, pageThumbnailSize.height * factor);
    
    for (GDPDFImageView *imageView in self.imageViews) {
        [imageView changeThumbnailSize:pageThumbnailSizeForCurrentScreen inOperationQueue:self.thumbnailsOperationQueue];
    }
}

@end

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
#import "GDPDFView.h"

#import "GDPDFScrollView.h"

@interface GDPDFView () <UIScrollViewDelegate, GDPDFViewDelegate>

@property (nonatomic, strong) GDPDFScrollView *scrollView;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) CGFloat lastZoomScale;

@end

@implementation GDPDFView

@synthesize filePathURL = _filePathURL;
@synthesize currentPageNumber = _currentPageNumber;
@synthesize totalPagesCount = _totalPagesCount;
@synthesize visibilityFactor = _visibilityFactor;
@synthesize shouldShowThumbnails = _shouldShowThumbnails;
@synthesize shouldShowActivityIndicator = _shouldShowActivityIndicator;
@synthesize maximumPageImageSize = _maximumPageImageSize;
@synthesize pageThumbnailSize = _pageThumbnailSize;

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (instancetype)init {
    return [self initWithFilePathURL:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame filePathURL:nil];
}

- (instancetype)initWithFrame:(CGRect)frame filePathURL:(NSURL *)filePathURL {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScrollViewWithFilePathURL:filePathURL];
    }
    return self;
}

- (instancetype)initWithFilePathURL:(NSURL *)filePathURL {
    return [self initWithFrame:CGRectZero filePathURL:filePathURL];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupScrollViewWithFilePathURL:nil];
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods

- (void)clean {
    self.filePathURL = nil;
}

#pragma mark -
#pragma mark - Private Methods

#pragma mark - Default Setups

- (void)setupScrollViewWithFilePathURL:(NSURL *)filePathURL {
    self.scrollView = [[GDPDFScrollView alloc] initWithFilePathURL:filePathURL PDFViewDelegate:self];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setBackgroundColor:self.backgroundColor];
    [self.scrollView setDelegate:self];
    [self addSubview:self.scrollView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
}

#pragma mark -
#pragma mark - Protocols Implementation

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset != scrollView.contentOffset.y) {
        [self.scrollView renderContent];
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.lastZoomScale != scrollView.zoomScale) {
        [self.scrollView centerContent];
        [self.scrollView renderContent];
    }
    
    self.lastZoomScale = scrollView.zoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.scrollView contentView];
}

#pragma mark - PDFViewDelegate

- (void)PDFViewDidBeginLoading:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view {
    NSLog(@"PDFViewDidBeginLoading");
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFViewDidBeginLoading:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFViewDidBeginLoading:self];
        });
    }
}

- (void)PDFViewDidEndLoading:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view {
    NSLog(@"PDFViewDidEndLoading");
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFViewDidEndLoading:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFViewDidEndLoading:self];
        });
    }
}

- (void)PDFView:(GDPDFScrollView *)scrollView didChangePage:(NSInteger)pageNumber {
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFView:didChangePage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFView:self didChangePage:pageNumber];
        });
    }
}

- (void)PDFView:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view configurePageVectorImage:(OHVectorImage *)vectorImage atPageNumber:(NSInteger)pageNumber {
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFView:configurePageVectorImage:atPageNumber:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFView:self configurePageVectorImage:vectorImage atPageNumber:pageNumber];
        });
    }
}

#pragma mark - 
#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self.scrollView setBackgroundColor:backgroundColor];
}

- (void)setFilePathURL:(NSURL *)filePathURL {
    [self.scrollView setFilePathURL:filePathURL];
}

- (void)setVisibilityFactor:(CGFloat)visibilityFactor {
    [self.scrollView setVisibilityFactor:visibilityFactor];
}

- (void)setShouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator {
    [self.scrollView setShouldShowActivityIndicator:shouldShowActivityIndicator];
}

- (void)setShouldShowThumbnails:(BOOL)shouldShowThumbnails {
    [self.scrollView setShouldShowThumbnails:shouldShowThumbnails];
}

- (void)setMaximumPageImageSize:(CGSize)maximumPageImageSize {
    [self.scrollView setMaximumPageImageSize:maximumPageImageSize];
}

- (void)setPageThumbnailSize:(CGSize)pageThumbnailSize {
    [self.scrollView setPageThumbnailSize:pageThumbnailSize];
}

#pragma mark - Getters

- (NSURL *)filePathURL {
    return [self.scrollView filePathURL];
}

- (NSInteger)currentPageNumber {
    return [self.scrollView currentPageNumber];
}

- (NSInteger)totalPagesCount {
    return [self.scrollView totalPagesCount];
}

- (CGFloat)visibilityFactor {
    return [self.scrollView visibilityFactor];
}

- (BOOL)shouldShowActivityIndicator {
    return [self.scrollView shouldShowActivityIndicator];
}

- (BOOL)shouldShowThumbnails {
    return [self.scrollView shouldShowThumbnails];
}

- (CGSize)maximumPageImageSize {
    return [self.scrollView maximumPageImageSize];
}

- (CGSize)pageThumbnailSize {
    return [self.scrollView pageThumbnailSize];
}

@end

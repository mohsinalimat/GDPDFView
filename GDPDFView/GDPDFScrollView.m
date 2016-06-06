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

#import "GDPDFScrollView.h"

#import <OHPDFImage/OHPDFDocument.h>
#import <OHPDFImage/OHPDFPage.h>
#import <OHPDFImage/OHVectorImage.h>

#import "GDPDFContainerView.h"
#import "GDPDFImageView.h"

@interface GDPDFScrollView ()

@property (nonatomic, strong) GDPDFContainerView *containerView;

@property (nonatomic, readwrite) NSInteger currentPageNumber;
@property (nonatomic, readwrite) NSInteger totalPagesCount;
@property (nonatomic) CGRect lastBounds;

@property (nonatomic, strong) NSOperation *documentOperation;
@property (nonatomic, strong) NSOperation *pagesOperation;

@end

@implementation GDPDFScrollView

@synthesize filePathURL = _filePathURL;
@synthesize PDFViewDelegate = _PDFViewDelegate;
@synthesize visibilityFactor = _visibilityFactor;
@synthesize shouldShowThumbnails = _shouldShowThumbnails;
@synthesize shouldShowActivityIndicator = _shouldShowActivityIndicator;
@synthesize maximumPageImageSize = _maximumPageImageSize;
@synthesize pageThumbnailSize = _pageThumbnailSize;

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (instancetype)initWithFilePathURL:(NSURL *)filePathURL {
    self = [super init];
    if (self) {
        self.filePathURL = filePathURL;
        self.currentPageNumber = 0;
        self.totalPagesCount = 0;
        self.lastBounds = CGRectZero;
        self.bounces = NO;
        
        [self setupContainerViewWithFilePathURL:filePathURL];
    }
    return self;
}

- (instancetype)initWithFilePathURL:(NSURL *)filePathURL PDFViewDelegate:(id<GDPDFViewDelegate>)PDFViewDelegate {
    self = [super init];
    if (self) {
        self.filePathURL = filePathURL;
        self.PDFViewDelegate = PDFViewDelegate;
        self.currentPageNumber = 0;
        self.totalPagesCount = 0;
        self.lastBounds = CGRectZero;
        self.bounces = NO;
        
        [self setupContainerViewWithFilePathURL:filePathURL];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutContainerViewIfNeeded];
}

- (void)dealloc {
    [self cancelDocumentOperation];
    [self cancelPagesOperation];
}

#pragma mark -
#pragma mark - Public Methods

- (void)centerContent {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    [self.containerView setFrame:contentsFrame];
}

- (void)renderContent {
    if (!self.filePathURL || CGRectGetWidth(self.bounds) == 0.0f || CGRectGetHeight(self.bounds) == 0.0f) {
        return;
    }
    
    CGRect visibleRect = [self convertRect:self.bounds toView:self.containerView];
    visibleRect.origin.x = 0.0f;
    visibleRect.size.width = self.containerView.width;
    
    [self cancelPagesOperation];
    
    __weak GDPDFScrollView *wSelf = self;
    self.pagesOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong GDPDFScrollView *sSelf = wSelf;
        NSInteger newCurrentPageNumber = [self.containerView renderPagesInRect:visibleRect withCurrentPage:self.currentPageNumber];
        [sSelf setCurrentPageNumber:newCurrentPageNumber];
    }];
    
    [self.pagesOperation start];
}

- (void)clean {
    self.filePathURL = nil;
}

#pragma mark -
#pragma mark - Private Methods

#pragma mark - Default Setups

- (void)setupContainerViewWithFilePathURL:(NSURL *)filePathURL {
    [self cancelDocumentOperation];
    [self cancelPagesOperation];
    [self viewDidBeginLoading];
    
    __weak GDPDFScrollView *wSelf = self;
    [self imageViewsWithFilePathURL:filePathURL completion:^(NSArray *imageViews) {
        __strong GDPDFScrollView *sSelf = wSelf;
        sSelf.containerView = [[GDPDFContainerView alloc] initWithImageViews:imageViews];
        [sSelf addSubview:sSelf.containerView];
        
        [sSelf layoutContainerView];
        [sSelf viewDidEndLoading];
    }];
}

#pragma mark - PDF Document & Pages Methods

- (OHPDFDocument *)documentWithFilePathURL:(NSURL *)filePathURL {
    return [OHPDFDocument documentWithURL:filePathURL];
}

- (NSArray *)documentPagesWithDocument:(OHPDFDocument *)document {
    size_t pagesCount = [document pagesCount];
    NSMutableArray *documentPages = [NSMutableArray arrayWithCapacity:pagesCount];
    for (size_t i = 1; i <= pagesCount; i++) {
        OHPDFPage *page = [document pageAtIndex:i];
        if (!page) {
            continue;
        }
        [documentPages addObject:page];
    }
    
    [self setTotalPagesCount:[documentPages count]];
    
    return documentPages;
}

- (void)imageViewsWithFilePathURL:(NSURL *)filePathURL completion:(void (^)(NSArray *imageViews))completion {
    [self cancelDocumentOperation];
    [self cancelPagesOperation];
    
    if (!filePathURL) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    __weak GDPDFScrollView *wSelf = self;
    self.documentOperation = [NSBlockOperation blockOperationWithBlock:^{
        __strong GDPDFScrollView *sSelf = wSelf;
        
        OHPDFDocument *document = [sSelf documentWithFilePathURL:filePathURL];
        NSArray *documentPages = [sSelf documentPagesWithDocument:document];
        
        NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:[documentPages count]];
        for (OHPDFPage *page in documentPages) {
            NSInteger pageNumber = [documentPages indexOfObject:page];
            OHVectorImage *vectorImage = [OHVectorImage imageWithPDFPage:page];
            
            if (sSelf.PDFViewDelegate && [sSelf.PDFViewDelegate respondsToSelector:@selector(PDFView:configurePageVectorImage:atPageNumber:)]) {
                [sSelf.PDFViewDelegate PDFView:sSelf configurePageVectorImage:vectorImage atPageNumber:pageNumber];
            }
            
            GDPDFImageView *imageView = [[GDPDFImageView alloc] initWithVectorImage:vectorImage];
            [imageViews addObject:imageView];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imageViews);
            });
        }
    }];
    
    [self.documentOperation start];
}

- (void)changeDocumentWithFilePath:(NSURL *)filePathURL {
    [self viewDidBeginLoading];
    
    __weak GDPDFScrollView *wSelf = self;
    [self imageViewsWithFilePathURL:filePathURL completion:^(NSArray *imageViews) {
        __strong GDPDFScrollView *sSelf = wSelf;
        [sSelf setNewContentForContainerViewWithImageViews:imageViews];
        [sSelf viewDidEndLoading];
    }];
}

- (void)setNewContentForContainerViewWithImageViews:(NSArray *)imageViews {
    [self setContentOffset:CGPointMake(0.0f, 0.0f)];
    [self setCurrentPageNumber:0];
    
    [self.containerView setImageViews:imageViews];
    [self.containerView setMaximumPageImageSize:[self.containerView maximumPageImageSize]];
    [self.containerView setPageThumbnailSize:[self.containerView pageThumbnailSize]];
    
    [self zoomScaleToFill];
    [self renderContent];
}

#pragma mark - Layout & Zoom Methods

- (void)layoutContainerViewIfNeeded {
    if (CGRectEqualToRect(self.bounds, CGRectZero) || (CGRectGetWidth(self.bounds) == CGRectGetWidth(self.lastBounds) && CGRectGetHeight(self.bounds) == CGRectGetHeight(self.lastBounds))) {
        return;
    }
    
    self.lastBounds = self.bounds;
    
    [self layoutContainerView];
}

- (void)layoutContainerView {
    if (CGSizeEqualToSize([self.containerView maximumPageImageSize], CGSizeZero) || CGSizeEqualToSize([self.containerView pageThumbnailSize], CGSizeZero)) {
        CGFloat side = CGRectGetWidth(self.bounds);
        [self setMaximumPageImageSize:CGSizeMake(side, side)];
        [self setPageThumbnailSize:CGSizeMake(side * 0.05f, side * 0.05f)];
        [self zoomScaleToFill];
    }
    
    [self renderContent];
}

- (void)zoomScaleToFill {
    [self.containerView setFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.containerView setTransform:CGAffineTransformIdentity];
    
    [self.containerView layoutImageViews];
    [self setContentSize:CGSizeMake(self.containerView.width, self.containerView.height)];
    
    CGFloat zoomScale = 1.0f;
    if (self.contentSize.width > 0.0f && self.contentSize.height > 0.0f) {
        if (self.containerView.width < self.containerView.height) {
            zoomScale = CGRectGetWidth(self.bounds) / self.contentSize.width;
        } else {
            zoomScale = CGRectGetHeight(self.bounds) / self.contentSize.height;
        }
    }
    
    CGFloat maxScale = MAX((zoomScale + 1.0f), 2.0f);
    
    self.minimumZoomScale = zoomScale;
    self.maximumZoomScale = maxScale;
    self.zoomScale = zoomScale;
}

#pragma mark - Support Methods

- (void)viewDidBeginLoading {
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFViewDidBeginLoading:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFViewDidBeginLoading:self];
        });
    }
}

- (void)viewDidEndLoading {
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFViewDidEndLoading:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFViewDidEndLoading:self];
        });
    }
}

- (BOOL)fileExistsAtPath:(NSString *)filePath {
    if (!filePath || [filePath isEqual:[NSNull null]]) {
        return NO;
    }
    
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) {
        return NO;
    }
    
    return YES;
}

- (void)cancelDocumentOperation {
    if (self.documentOperation) {
        if (![self.documentOperation isCancelled]) {
            [self.documentOperation cancel];
        }
        
        self.documentOperation = nil;
    }
}

- (void)cancelPagesOperation {
    if (self.pagesOperation) {
        if (![self.pagesOperation isCancelled]) {
            [self.pagesOperation cancel];
        }
        
        self.pagesOperation = nil;
    }
}

#pragma mark -
#pragma mark - Setters

- (void)setCurrentPageNumber:(NSInteger)currentPageNumber {
    if (currentPageNumber == _currentPageNumber || currentPageNumber < 0) {
        return;
    }
    
    _currentPageNumber = currentPageNumber;
    
    if (self.PDFViewDelegate && [self.PDFViewDelegate respondsToSelector:@selector(PDFView:didChangePage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.PDFViewDelegate PDFView:self didChangePage:currentPageNumber];
        });
    }
}

- (void)setFilePathURL:(NSURL *)filePathURL {
    if ([self fileExistsAtPath:[filePathURL path]]) {
        _filePathURL = filePathURL;
    } else {
        _filePathURL = nil;
    }
    
    if (!self.containerView) {
        return;
    }
    
    [self changeDocumentWithFilePath:filePathURL];
}

- (void)setVisibilityFactor:(CGFloat)visibilityFactor {
    [self.containerView setVisibilityFactor:visibilityFactor];
}

- (void)setShouldShowActivityIndicator:(BOOL)shouldShowActivityIndicator {
    [self.containerView setShouldShowActivityIndicator:shouldShowActivityIndicator];
}

- (void)setShouldShowThumbnails:(BOOL)shouldShowThumbnails {
    [self.containerView setShouldShowThumbnails:shouldShowThumbnails];
}

- (void)setMaximumPageImageSize:(CGSize)maximumPageImageSize {
    [self.containerView setMaximumPageImageSize:maximumPageImageSize];
}

- (void)setPageThumbnailSize:(CGSize)pageThumbnailSize {
    [self.containerView setPageThumbnailSize:pageThumbnailSize];
}

#pragma mark - Getters

- (UIView *)contentView {
    return self.containerView;
}

- (CGFloat)visibilityFactor {
    return [self.containerView visibilityFactor];
}

- (BOOL)shouldShowActivityIndicator {
    return [self.containerView shouldShowActivityIndicator];
}

- (BOOL)shouldShowThumbnails {
    return [self.containerView shouldShowThumbnails];
}

- (CGSize)maximumPageImageSize {
    return [self.containerView maximumPageImageSize];
}

- (CGSize)pageThumbnailSize {
    return [self.containerView pageThumbnailSize];
}

@end

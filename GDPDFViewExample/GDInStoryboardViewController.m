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

#import "GDInStoryboardViewController.h"

#import "GDPDFView.h"

@interface GDInStoryboardViewController () <GDPDFViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *pageCounterLabel;
@property (nonatomic, weak) IBOutlet GDPDFView *PDFView;

@end

@implementation GDInStoryboardViewController

#pragma mark -
#pragma mark - Init Methods & Superclass Overriders

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.PDFView setPDFViewDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updatePageCounterLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Private Methods

#pragma mark - Support Methods

- (NSURL *)PDFFilePathURL {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MyCoreLocationLecture" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    return url;
}

- (void)updatePageCounterLabel {
    [self.pageCounterLabel setText:[NSString stringWithFormat:@"%@ / %@", @([self.PDFView currentPageNumber] + 1), @([self.PDFView totalPagesCount])]];
}

#pragma mark -
#pragma mark - Controls Actions

- (IBAction)cleanButtonAction:(id)sender {
    [self.pageCounterLabel setHidden:YES];
    [self.PDFView clean];
}

- (IBAction)loadFileButtonAction:(id)sender {
    [self.PDFView setFilePathURL:[self PDFFilePathURL]];
    [self updatePageCounterLabel];
    [self.pageCounterLabel setHidden:NO];
}

#pragma mark -
#pragma mark - Protocols Implementation

#pragma mark - GDPDFViewDelegate

- (void)PDFViewDidBeginLoading:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view {
    NSLog(@"PDFViewDidBeginLoading:%@", view);
}

- (void)PDFViewDidEndLoading:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view {
    NSLog(@"PDFViewDidEndLoading:%@", view);
}

- (void)PDFView:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view didChangePage:(NSInteger)pageNumber {
    NSLog(@"PDFView:%@ didChangePage:%@", view, @(pageNumber));
    [self updatePageCounterLabel];
}

- (void)PDFView:(id<GDPDFViewProperties,GDPDFContainerViewProperties>)view configurePageVectorImage:(OHVectorImage *)vectorImage atPageNumber:(NSInteger)pageNumber {
    NSLog(@"PDFView:%@ configurePageVectorImage:%@ atPageNumber:%@", view, vectorImage, @(pageNumber));
}

@end

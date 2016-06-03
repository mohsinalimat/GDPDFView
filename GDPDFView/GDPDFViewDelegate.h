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

#ifndef GDPDFViewDelegate_h
#define GDPDFViewDelegate_h

#import "GDPDFViewProperties.h"
#import "GDPDFContainerViewProperties.h"

@class OHVectorImage;

@protocol GDPDFViewDelegate <NSObject>

@optional
/**
 Indicates when PDF file begin loading
 */
- (void)PDFViewDidBeginLoading:(id<GDPDFViewProperties, GDPDFContainerViewProperties>)view;

/**
 Indicates when PDF file end loading and content is ready
 */
- (void)PDFViewDidEndLoading:(id<GDPDFViewProperties, GDPDFContainerViewProperties>)view;

/**
 Indicates when current page number is changed, page numbering begins from 0
 */
- (void)PDFView:(id<GDPDFViewProperties, GDPDFContainerViewProperties>)view didChangePage:(NSInteger)pageNumber;

/**
 Indicates when new PDF page is created, vectorImage object of OHVectormImage can be customized using class properties
 */
- (void)PDFView:(id<GDPDFViewProperties, GDPDFContainerViewProperties>)view configurePageVectorImage:(OHVectorImage *)vectorImage atPageNumber:(NSInteger)pageNumber;

@end

#endif /* GDPDFViewDelegate_h */

#GDPDFView
Vertical scroll view to display PDF file based on using OHPDFImage https://github.com/AliSoftware/OHPDFImage.

![Alt text](GDPDFView.gif?raw=true "Example gif")

## Installation
Simply add GDPDFVIew folder with files to your project, or use CocoaPods.

### Podfile
```
platform :ios, '8.0'
use_frameworks!

target 'project_name' do
	pod 'GDPDFView', '~> 1.0.0'
end
```

## Usage
You can use GDPDFView with IB or with code. 

### In Interface Builder
Add an UIView instance to your view controller and change its class to GDPDFView.

Then in code you can set delegate

```
[self.lecturePDFView setPDFViewDelegate:self];
```
and set PDF file path URL

```
NSString *path = [[NSBundle mainBundle] pathForResource:@"MyCoreLocationLecture" ofType:@"pdf"];
NSURL *url = [NSURL fileURLWithPath:path];

[self.lecturePDFView setFilePathURL:url];
```

### In Code

```
NSString *path = [[NSBundle mainBundle] pathForResource:@"MyCoreLocationLecture" ofType:@"pdf"];
NSURL *url = [NSURL fileURLWithPath:path];

self.lecturePDFView = [[GDPDFView alloc] initWithFilePathURL:url];
[self.lecturePDFView setPDFViewDelegate:self];
[self.lecturePDFView setFrame:self.view.bounds];
[self.view insertSubview:self.lecturePDFView atIndex:0];
```

### GDPDFViewDelegate

```
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
```

See exemple project for more details.


## Requirements
- iOS 8.0+

## License
GDPDFView is available under the MIT license. See the LICENSE file for more info.

//
//  ViewController.m
//  CreatingPDF
//
//  Created by barroso on 6/27/18.
//  Copyright © 2018 Orionbelt.com LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)createPDF:(id)sender {
    
    //Get Document Directory path
    NSArray * dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *enterSubject = @"testing";
    NSString *enterText = @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    
    //Define path for PDF file
    NSString * documentPath = [[dirPath objectAtIndex:0] stringByAppendingPathComponent:enterSubject];
    
    // Prepare the text using a Core Text Framesetter.
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (__bridge CFStringRef)enterText, NULL);
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToFile(documentPath, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            
            do {
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
                [self drawPageNbr:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                currentRange = *[self updatePDFPage:currentPage setTextRange:&currentRange setFramesetter:&framesetter];
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
        } else {
            NSLog(@"Could not create the framesetter..");
        }
        // Release the attributed string.
        CFRelease(currentText);
    } else {
        NSLog(@"currentText could not be created");
    }
}


-(void)drawPageNbr:(int)pageNumber{
    NSString *setPageNum = [NSString stringWithFormat:@"Page %d", pageNumber];
    UIFont *pageNbrFont = [UIFont systemFontOfSize:14];
    
    CGSize maxSize = CGSizeMake(612, 72);
    CGSize pageStringSize = [setPageNum sizeWithFont:pageNbrFont
                                   constrainedToSize:maxSize
                                       lineBreakMode:UILineBreakModeClip];
    
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    [setPageNum drawInRect:stringRect withFont:pageNbrFont];
}


-(CFRange*)updatePDFPage:(int)pageNumber setTextRange:(CFRange*)pageRange setFramesetter:(CTFramesetterRef*)framesetter{
    // Get the graphics context.
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(*framesetter, *pageRange,
                                                   framePath, NULL);
    CGPathRelease(framePath);
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    // Update the current range based on what was drawn.
    *pageRange = CTFrameGetVisibleStringRange(frameRef);
    pageRange->location += pageRange->length;
    pageRange->length = 0;
    CFRelease(frameRef);
    return pageRange;
}



@end

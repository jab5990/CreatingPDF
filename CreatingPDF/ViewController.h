//
//  ViewController.h
//  CreatingPDF
//
//  Created by barroso on 6/27/18.
//  Copyright © 2018 Orionbelt.com LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface ViewController : UIViewController

- (IBAction)createPDF:(id)sender;

-(void)drawPageNbr:(int)pageNumber;
-(CFRange*)updatePDFPage:(int)pageNumber setTextRange:(CFRange*)pageRange setFramesetter:(CTFramesetterRef*)framesetter;


@end

